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
        
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = self.city.managedObjectContext
        
        let dataParser = ParsingManager(context: backgroundContext)
        let dataLoader = JSONLoader()
        let APIKey = APIKeys().getRandomAPIKey()
        
        let networkManager = NetworkManager(dataParser: dataParser, dataLoader: dataLoader, APIKey: APIKey)
        
        return WeatherInfoViewModel(city: self.city, networkManager: networkManager, context: backgroundContext)
    }
}
