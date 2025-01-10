//
//  CityViewModel.swift
//  Weather
//
//  Created by Вадим on 04.12.2024.
//

import Foundation
import CoreData

class CityViewModel: CityViewModelProtocol {
    
    // MARK: - Properties
    
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
    
    // MARK: - Initializers
    
    init(city: CityDataProviding) {
        self.city = city
    }
    
    // MARK: - Create view models
    
    func createWeatherInfoViewModel() -> WeatherInfoViewModelProtocol {
        let dataLoader = JSONLoader()
        let APIKey = APIKeys().getRandomAPIKey()                
        return WeatherInfoViewModel(city: self.city, dataLoader: dataLoader, APIKey: APIKey)
    }
}
