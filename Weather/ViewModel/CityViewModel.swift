//
//  CityViewModel.swift
//  Weather
//
//  Created by Вадим on 04.12.2024.
//

import Foundation

class CityViewModel: CityViewModelProtocol {
    
    private let city: CityDataProviding
    
    var cityName: String {
        self.city.name
    }
    var isDayTime: Bool {
        self.city.currentWeather?.isDayTime ?? true
    }
    var cityId: Int {
        Int(self.city.id)
    }
    
    init(city: CityDataProviding) {
        self.city = city
    }
    
    func createWeatherInfoViewModel() -> WeatherInfoViewModelProtocol {
        return WeatherInfoViewModel(city: self.city)
    }
}
