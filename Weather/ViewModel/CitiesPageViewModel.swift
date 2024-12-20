//
//  CitiesPageViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

import CoreData

class CitiesPageViewModel {
    
    // MARK: - Properties
    
    let frc: NSFetchedResultsController<City>
    
    private var citiesList: [City] {
        self.frc.fetchedObjects ?? []
    }
    
    var citiesCount: Int {
        return self.citiesList.count
    }
    
    // MARK: - Initializers
    
    init(fetchedResultsController: NSFetchedResultsController<City>) {
        self.frc = fetchedResultsController
//        self.frc
    }
    
    // MARK: - CRUD
        
    func firstIndexInCityList(of city: City) -> Int? {
        return self.citiesList.firstIndex(of: city)
    }
    
    // MARK: - Create view models
    
    func createCityViewModel(withIndex index: Int) -> CityViewModel{
        return CityViewModel.init(city: self.citiesList[index])
    }
        
    func createCitiesListViewModel() -> CitiesListViewModel {
        return CitiesListViewModel(fetchedResultsController: self.frc)
    }
}
