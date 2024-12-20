//
//  CitiesListViewModel.swift
//  Weather
//
//  Created by Вадим on 09.12.2024.
//

import Foundation
import CoreData

class CitiesListViewModel: NSObject {
    
    // MARK: - Properties
        
    let frc: NSFetchedResultsController<City>
    
    var citiesList: [City] {
        self.frc.fetchedObjects ?? []
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
    
    func getIndexPathsArray(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> [IndexPath] {
        
        let closedRange: ClosedRange<Int>
        
        if sourceIndexPath < destinationIndexPath {
            closedRange = sourceIndexPath.row...destinationIndexPath.row
        } else {
            closedRange = destinationIndexPath.row...sourceIndexPath.row
        }
        
        return Array(closedRange).map({ IndexPath(row: $0, section: sourceIndexPath.section) })
    }
    
    // MARK: - Create view model
    
    func createSearchScreenViewModel() -> SearchScreenViewModel {
        return SearchScreenViewModel(fetchedResultsController: self.frc)
    }
}
