//
//  HourlyForecast.swift
//  Weather 2
//
//  Created by Вадим on 15.01.2022.
//

import Foundation

class HourlyForecast: WeatherInfo {
    
    // MARK: Properties
    
//    var 
    
    let forecastTime: Date
    
    // MARK: Initializers
    
    init(forecastTime: Date, temperatureCelsius: Int, weatherIcon: Int, weatherText: String) {
        self.forecastTime = forecastTime
        super.init(weatherIcon: weatherIcon, weatherText: weatherText, temperatureCelsius: temperatureCelsius)
    }
    
    
    // MARK: Codable
    
    public enum CodingKeys: CodingKey {
        case forecastTime
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.forecastTime = try container.decode(Date.self, forKey: .forecastTime)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.forecastTime, forKey: .forecastTime)
    }
        
}
