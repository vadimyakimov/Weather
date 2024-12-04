//
//  MainNavigationViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

class MainNavigationViewModel: AppViewModel {
        
    // MARK: - Working with data
    
    func addNewCity(_ city: City) {
        
        CitiesCoreDataStack.shared.addCity(city)
        
        if city.isLocated {
            if self.citiesList.first?.isLocated == true {
                CitiesCoreDataStack.shared.deleteCity(at: 0)
            }
            CitiesCoreDataStack.shared.moveCity(at: self.citiesCount - 1, to: 0)
        }
    }
    
    
}


