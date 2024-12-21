//
//  SearchScreenViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

import Foundation
import CoreLocation
import CoreData

class SearchScreenViewModel: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: SearchScreenViewControllerDelegate?
    
    var citiesAutocompleteArray = Bindable([City]())
    var citiesCount: Int {
        get {
            return self.citiesAutocompleteArray.value.count
        }
    }
    
    private let frc: NSFetchedResultsController<City>
    private let tempContext: NSManagedObjectContext
    private var savedCitiesList: [City]? {
        return self.frc.fetchedObjects
    }
    
    private lazy var locationManager = CLLocationManager()
    var isLocationLoading = Bindable(false)
    var locationError = Bindable<Error?>(nil)
    
    private lazy var autocompleteTimer = Timer()
    private let timerInterval = 0.7
    
    // MARK: - Initializer
    
    init(fetchedResultsController: NSFetchedResultsController<City>) {
        self.frc = fetchedResultsController
        self.tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.tempContext.parent = self.frc.managedObjectContext
        super.init()
    }
    
    // MARK: - Save to Core Data
    
    private func addNewCity(_ city: City) -> Int {
        
        let count = self.savedCitiesList?.count ?? 0
        
        let context = self.frc.managedObjectContext
        let id: Int
        
        if city.isLocated {
            self.freeAtFirstIndex()
            id = 0
        } else {
            id = count
        }
        
        let _ = City(context: context,
                     id: Int16(id),
                     key: city.key,
                     name: city.name,
                     isLocated: city.isLocated)
        
        self.saveContext()
        
        return id
    }
    
    private func deleteFirstCity() {
        
        guard let city = self.frc.fetchedObjects?.first else { return }
        
        let context = self.frc.managedObjectContext
        
        if let currentWeather = city.currentWeather {
            context.delete(currentWeather)
        }
        if let hourlyForecast = city.hourlyForecast?.array as? [HourlyForecast] {
            for item in hourlyForecast {
                context.delete(item)
            }
        }
        if let dailyForecast = city.dailyForecast?.array as? [DailyForecast] {
            for item in dailyForecast {
                context.delete(item)
            }
        }
        context.delete(city.lastUpdated)
        context.delete(city)
    }
    
    private func freeAtFirstIndex() {
        guard let savedCitiesList = self.savedCitiesList else { return }
        
        if savedCitiesList.first?.isLocated == true {
            self.deleteFirstCity()
        } else {
            savedCitiesList.forEach({ $0.id += 1 })
        }
    }
    
    private func saveContext() {
        do {
            try self.frc.managedObjectContext.save()
            try self.frc.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    // MARK: - Getting data
    
    func fetchAutocompleteArray(for searchText: String) {
        
        self.autocompleteTimer.invalidate()
        self.autocompleteTimer = Timer.scheduledTimer(withTimeInterval: self.timerInterval,
                                                      repeats: false,
                                                      block: { [unowned self] _ in
            NetworkManager.shared.autocomplete(for: searchText, context: self.tempContext) { [unowned self] cityArray in
                self.citiesAutocompleteArray.value = cityArray
                self.autocompleteTimer.invalidate()
            }
        })
    }
    
    func getCity(atIndexPath indexPath: IndexPath) -> City? {
        guard indexPath.section == 1 else { return nil }
        return self.citiesAutocompleteArray.value[safe: indexPath.row]
    }
    
    // MARK: - Detecting city funcs
    
    func handleSelectedRow(at indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.requestLocation()
        } else {
            guard let city = self.getCity(atIndexPath: indexPath) else { return }
            
            if let index = self.savedCitiesList?.firstIndex(where: { $0.key == city.key }) {
                self.delegate?.searchScreenViewController(didDirectToCityWithIndex: index)
            } else {
                let index = self.addNewCity(city)
                self.delegate?.searchScreenViewController(didDirectToCityWithIndex: index)
            }
        }
    }
    
    private func requestLocation() {
        
        self.isLocationLoading.value = true
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestLocation()
    }
}

// MARK: -
// MARK: - Location Manager Delegate

extension SearchScreenViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else {
            self.locationError.value = NSError()
            return
        }
        NetworkManager.shared.geopositionCity(for: location.coordinate) { [unowned self] city in
            let index = self.addNewCity(city)
            self.delegate?.searchScreenViewController(didDirectToCityWithIndex: index)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        self.isLocationLoading.value = false
        
        if #available(iOS 14.0, *), locationManager.authorizationStatus == .notDetermined {
            return
        } else {
            self.locationError.value = error
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.isLocationLoading.value = true
            manager.requestLocation()
        }
    }
}
