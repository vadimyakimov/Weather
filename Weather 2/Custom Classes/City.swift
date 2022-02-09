//
//  City.swift
//  Weather 2
//
//  Created by Вадим on 13.01.2022.
//

import Foundation
//
class City: Codable, Equatable {
      
    
    // MARK: Properties
    
    var id: String
    let name: String
        
    var currentWeather: CurrentWeather?
    var hourlyForecast: [HourlyForecast]?
    var dailyForecast: [DailyForecast]?
    
    var lastUpdated: LastUpdated
    
    let isLocated: Bool
    
    // MARK: Initializers
    
    init(id: String, name: String, isLocated: Bool = false) {
        self.id = id
        self.name = name
        self.isLocated = isLocated
        self.lastUpdated = LastUpdated()
    }
    
    // MARK: Equatable
    
    static func == (lhs: City, rhs: City) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
    
}
