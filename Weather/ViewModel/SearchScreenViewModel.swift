//
//  SearchScreenViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

import Foundation
import CoreLocation
import CoreData

class SearchScreenViewModel: NSObject, SearchScreenViewModelProtocol {
    
    // MARK: - Properties
    
    weak var delegate: SearchScreenViewControllerDelegate?
    
    private let networkManager: CityProviding
    
    var citiesAutocompleteArray = Bindable([CityDataProviding]())
    var citiesCount: Int {
        get {
            return self.citiesAutocompleteArray.value.count
        }
    }
    
    private let frc: NSFetchedResultsController<City>
    private var savedCitiesList: [CityDataProviding]? {
        return self.frc.fetchedObjects
    }
    
    private lazy var locationManager = CLLocationManager()
    let isLocationLoading: Bindable<GeoDetectingState> = Bindable(.initial)
        
    private var autocompleteTask: Task<Void, Error>?
    private let taskDelay = 0.7
    
    // MARK: - Initializer
    
    init(fetchedResultsController: NSFetchedResultsController<City>, networkManager: CityProviding) {
        self.frc = fetchedResultsController
        self.networkManager = networkManager
        super.init()
    }
    
    // MARK: - Save to Core Data
    
    private func addNewCity(_ city: CityDataProviding) -> Int {
        
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
    
    private func deleteCity(at index: Int) {
        
        guard let city = self.savedCitiesList?[index] else { return }
        
        let context = self.frc.managedObjectContext
        
        if let currentWeather = city.currentWeather {
            context.delete(currentWeather)
        }
        if let hourlyForecast = city.hourlyForecast?.array as? [CityManagedEntity] {
            for item in hourlyForecast {
                context.delete(item)
            }
        }
        if let dailyForecast = city.dailyForecast?.array as? [CityManagedEntity] {
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
            self.deleteCity(at: 0)
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
        
        self.autocompleteTask?.cancel()
        
        self.autocompleteTask = Task { [unowned self] in
            
                try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
                guard !Task.isCancelled else { return }
            
            guard let citiesArray = await self.networkManager.autocomplete(for: searchText) else { return }
                self.citiesAutocompleteArray.value = citiesArray
        }
    }
    
    func city(at index: Int) -> CityDataProviding? {
        return self.citiesAutocompleteArray.value[safe: index]
    }
    
    // MARK: - Detecting city funcs
    
    func handleSelectedRow(at indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.requestLocation()
        } else {
            guard let city = self.city(at: indexPath.row) else { return }
            
            if let index = self.savedCitiesList?.firstIndex(where: { $0.key == city.key }) {
                Task { [unowned self] in
                    await self.delegate?.searchScreenViewController(didDirectToCityWithIndex: index)
                }
            } else {
                let index = self.addNewCity(city)
                Task { [unowned self] in
                    await self.delegate?.searchScreenViewController(didDirectToCityWithIndex: index)
                }
            }
        }
    }
    
    private func requestLocation() {
        
        self.isLocationLoading.value = .loading
        
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
            self.isLocationLoading.value = .error
            return
        }
        
        self.isLocationLoading.value = .initial
        
        Task { [unowned self] in
            let city = await self.networkManager.geopositionCity(for: location.coordinate)
            guard let city else { return }
            
            if let index = self.savedCitiesList?.firstIndex(where: { $0.key == city.key }) {
                self.deleteCity(at: index)
                self.savedCitiesList?.filter({ $0.id > index }).forEach({ $0.id -= 1 })
            }
            
            let index = self.addNewCity(city)
            await self.delegate?.searchScreenViewController(didDirectToCityWithIndex: index)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.isLocationLoading.value = .error
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.isLocationLoading.value = .loading
            manager.requestLocation()
        }
    }
}
