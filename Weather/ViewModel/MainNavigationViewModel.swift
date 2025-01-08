//
//  MainNavigationViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//
import CoreData

class MainNavigationViewModel: MainNavigationViewModelProtocol {
    
    // MARK: - Properties
    
    private let coreData = CitiesCoreDataStack()
    private let frc: NSFetchedResultsController<City>
        
    var isEmpty: Bool {
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
        
    func createCitiesPageViewModel() -> CitiesPageViewModelProtocol {
        return CitiesPageViewModel(fetchedResultsController: self.frc)
    }
    
    func createSearchScreenViewModel() -> SearchScreenViewModelProtocol {
        return SearchScreenViewModel(fetchedResultsController: self.frc)
    }
}

