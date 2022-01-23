//
//  City.swift
//  Weather 2
//
//  Created by Вадим on 13.01.2022.
//

import Foundation
//
class City: Codable {
    
    // MARK: Properties
    
    var id: String
    let name: String
    
    var lastUpdated: Date?
    
    var currentWeather: CurrentWeather?
    var hourlyForecast: [HourlyForecast]?
    var dailyForecast: [DailyForecast]?
    
    let isLocated: Bool
    
    // MARK: Initializers
    
    init(id: String, name: String, isLocated: Bool = false) {
        self.id = id
        self.name = name
        self.isLocated = isLocated
    }
    
}
