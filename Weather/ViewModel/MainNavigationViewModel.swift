//
//  MainNavigationViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

class MainNavigationViewModel {
        
    var isSearchRoot: Bool {
        return CitiesCoreDataStack.shared.citiesList.isEmpty
    }
    var citiesCount: Int {
        return CitiesCoreDataStack.shared.citiesList.count
    }
           
    // MARK: - Working with data
    
    func addNewCity(_ city: City) {
        
        CitiesCoreDataStack.shared.addCity(city)
        
        if city.isLocated {
            if CitiesCoreDataStack.shared.citiesList.first?.isLocated == true {
                CitiesCoreDataStack.shared.deleteCity(at: 0)
            }
            CitiesCoreDataStack.shared.moveCity(at: self.citiesCount - 1, to: 0)
        }
    }
    
    func firstIndexInCityList(of city: City) -> Int? {
        return CitiesCoreDataStack.shared.citiesList.firstIndex(of: city)
    }
    
    func createCitiesPageViewModel() -> CitiesPageViewModel {
        return CitiesPageViewModel(citiesList: CitiesCoreDataStack.shared.citiesList)
    }
    
}


