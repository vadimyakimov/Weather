//
//  CityViewModel.swift
//  Weather
//
//  Created by Вадим on 04.12.2024.
//

import Foundation

class CityViewModel {
    
    let city: City
    
    init(city: City) {
        self.city = city
    }
    
    func createWeatherInfoViewModel() -> WeatherInfoViewModel {
        return WeatherInfoViewModel(city: self.city)
    }
}
