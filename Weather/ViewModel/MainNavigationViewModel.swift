//
//  MainNavigationViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//
import CoreData

class MainNavigationViewModel {
    
    // MARK: - Properties
    
    private let coreData = CitiesCoreDataStack.shared
    private let frc: NSFetchedResultsController<City>
        
    var isSearchRoot: Bool {
        return self.frc.fetchedObjects?.isEmpty ?? true
    }
    
    // MARK: - Initializers
    
    init() {
        let fetchRequest = City.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(City.id), ascending: true)]
        let context = self.coreData.context
        
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: context,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        try? self.frc.performFetch()
    }
       
    // MARK: - Create view models
        
    func createCitiesPageViewModel() -> CitiesPageViewModel {
        return CitiesPageViewModel(fetchedResultsController: self.frc)
    }
    
    func createSearchScreenViewModel() -> SearchScreenViewModel {
        return SearchScreenViewModel(fetchedResultsController: self.frc)
    }
}

