//
//  CitiesPageViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

class CitiesPageViewModel {
    
    let citiesList: [City]
        
    init(citiesList: [City]) {
        self.citiesList = citiesList
    }    
    
    func firstIndexInCityList(of city: City) -> Int? {
        return self.citiesList.firstIndex(of: city)
    }
    
    func createCityViewModel(withIndex index: Int) -> CityViewModel{
        return CityViewModel.init(city: self.citiesList[index])
    }
}
