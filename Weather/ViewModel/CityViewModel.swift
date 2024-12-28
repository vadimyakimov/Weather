//
//  CityViewModel.swift
//  Weather
//
//  Created by Вадим on 04.12.2024.
//

import Foundation

class CityViewModel {
    
    private let city: City
    
    var cityName: String {
        self.city.name
    }
    var isDayTime: Bool? {
        self.city.currentWeather?.isDayTime
    }
    var cityId: Int {
        Int(self.city.id)
    }
    
    init(city: City) {
        self.city = city
    }
    
    func createWeatherInfoViewModel() -> WeatherInfoViewModel {
        return WeatherInfoViewModel(city: self.city)
    }
}
