//
//  CurrentWearher.swift
//  Weather 2
//
//  Created by Вадим on 14.01.2022.
//

import Foundation

class CurrentWeather: WeatherInfo {
    
    // MARK: Properties
    
    let isDayTime: Bool
    
    // MARK: Initializers
    
    init(isDayTime: Bool, temperatureCelsius: Int, weatherIcon: Int, weatherText: String) {
        self.isDayTime = isDayTime
        super.init(weatherIcon: weatherIcon, weatherText: weatherText, temperatureCelsius: temperatureCelsius)
    }
    
    
    // MARK: Codable
    
    public enum CodingKeys: CodingKey {
        case isDayTime
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isDayTime = try container.decode(Bool.self, forKey: .isDayTime)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isDayTime, forKey: .isDayTime)
    }
        
}
