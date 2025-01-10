//
//  CitiesListViewModel.swift
//  Weather
//
//  Created by Вадим on 09.12.2024.
//

import Foundation
import CoreData

class CitiesListViewModel: NSObject, CitiesListViewModelProtocol {
    
    // MARK: - Properties
        
    let frc: NSFetchedResultsController<City>
    
    private var citiesList: [CityDataProviding] {
        self.frc.fetchedObjects ?? []
    }
    var hasLocatedCity: Bool {
        self.citiesList.first?.isLocated ?? false
    }
    var isEmpty: Bool {
        self.citiesList.isEmpty
    }
    var citiesCount: Int {
        self.citiesList.count
    }
    
    // MARK: - Initializers
    
    init(fetchedResultsController: NSFetchedResultsController<City>) {
        self.frc = fetchedResultsController
        
        super.init()
    }
    
    // MARK: - CRUD
    
    func removeCityAt(_ index: Int) {
        guard let city = self.citiesList[safe: index] else { return }
        
        self.delete(object: city.currentWeather)
        city.hourlyForecast?.array.forEach({ self.delete(object: $0) })
        city.dailyForecast?.array.forEach({ self.delete(object: $0) })
        self.delete(object: city.lastUpdated)
        self.delete(object: city)
        
        self.citiesList.filter({ $0.id > index }).forEach({ $0.id -= 1 })
                
        self.saveContext()
    }
    
    func moveCity(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        
        let sourceCity = self.citiesList[sourceIndex]
        
        let step: Int16 = sourceIndex > destinationIndex ? 1 : -1
        let range = sourceIndex > destinationIndex ? destinationIndex...sourceIndex : sourceIndex...destinationIndex
        
        self.citiesList.filter({ range ~= Int($0.id) }).forEach({ $0.id += step })

        sourceCity.id = Int16(destinationIndex)
        
        self.saveContext()
    }
    
    private func delete(object: Any?) {
        guard let object = object as? NSManagedObject else { return }
        self.frc.managedObjectContext.delete(object)
    }
    
    private func saveContext() {
        if self.frc.managedObjectContext.hasChanges {
            do {
                try self.frc.managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Flow funcs
    
    func city(at index: Int) -> CityDataProviding? {
        return self.citiesList[safe: index]
    }
    
    // MARK: - Create view model
    
    func createSearchScreenViewModel() -> SearchScreenViewModelProtocol {
        
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = self.frc.managedObjectContext
        
        let dataParser = ParsingManager(context: backgroundContext)
        let dataLoader = JSONLoader()
        let APIKey = APIKeys().getRandomAPIKey()
        
        let networkManager = NetworkManager(dataParser: dataParser, dataLoader: dataLoader, APIKey: APIKey)
        
        return SearchScreenViewModel(fetchedResultsController: self.frc, networkManager: networkManager)
    }
}
