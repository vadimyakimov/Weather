//
//  CitiesPageViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

import CoreData

class CitiesPageViewModel: CitiesPageViewModelProtocol {
  
    // MARK: - Properties
    
    private let frc: NSFetchedResultsController<City>
    
    private var citiesList: [CityDataProviding] {
        self.frc.fetchedObjects ?? []
    }
    
    var citiesCount: Int {
        return self.citiesList.count
    }
    
    // MARK: - Initializers
    
    init(fetchedResultsController: NSFetchedResultsController<City>) {
        self.frc = fetchedResultsController
    }
        
    // MARK: - Create view models
    
    func createCityViewModel(withIndex index: Int) -> CityViewModelProtocol{
        return CityViewModel.init(city: self.citiesList[index])
    }
        
    func createCitiesListViewModel() -> CitiesListViewModelProtocol {
        return CitiesListViewModel(fetchedResultsController: self.frc)
    }
}
