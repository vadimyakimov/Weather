//
//  MainNavigationViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

import Foundation

class MainNavigationViewModel {
    
    var isSearchRoot: Bool {
        get {
            CitiesCoreDataStack.shared.citiesList.isEmpty
        }
    }
}

extension MainNavigationViewModel: SearchScreenViewControllerDelegate {
    func searchScreenViewController(didSelectRowAt indexPath: IndexPath, autocompletedCity: City) {
        print("selected")
        if let index = CitiesCoreDataStack.shared.citiesList.firstIndex(of: autocompletedCity) {
            print(index)
            print(CitiesCoreDataStack.shared.citiesList.count)
            print(CitiesCoreDataStack.shared.citiesList.firstIndex(of: autocompletedCity))
            return
        }
        CitiesCoreDataStack.shared.addCity(autocompletedCity)
        print("selected")
    }
    
    func searchScreenViewController(didLoadLocaleCity city: City) {
        
    }
}
