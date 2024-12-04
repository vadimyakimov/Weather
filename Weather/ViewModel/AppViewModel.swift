//
//  AppViewModel.swift
//  Weather
//
//  Created by Вадим on 04.12.2024.
//

class AppViewModel {
    
    var citiesList: [City] {
        return CitiesCoreDataStack.shared.citiesList
    }
    
    var citiesCount: Int {
        return self.citiesList.count
    }
    
    var isSearchRoot: Bool {
        return self.citiesList.isEmpty
    }
    
    func firstIndexInCityList(of city: City) -> Int? {
        return self.citiesList.firstIndex(of: city)
    }
}
