//
//  MainNavigationViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

class MainNavigationViewModel {
    
    // MARK: - Properties
    
    private var citiesList: [City] {
        return CitiesCoreDataStack.shared.citiesList
    }
    
    var citiesCount: Int {
        return self.citiesList.count
    }
    
    var isSearchRoot: Bool {
        return self.citiesList.isEmpty
    }
    
    // MARK: - Working with data
    
    func addNewCity(_ city: City) {
        
        CitiesCoreDataStack.shared.addCity(city)
        
        if city.isLocated {
            if self.citiesList.first?.isLocated == true {
                CitiesCoreDataStack.shared.deleteCity(at: 0)
            }
            CitiesCoreDataStack.shared.moveCity(at: CitiesCoreDataStack.shared.citiesList.count - 1, to: 0)
        }
    }
    
    func firstIndexInCityList(of city: City) -> Int? {
        return self.citiesList.firstIndex(of: city)
    }
    
}


