////
////  HourlyForecast.swift
////  Weather 2
////
////  Created by Вадим on 15.01.2022.
////
//
//import Foundation
//
//class ZWeatherInfo: Codable {
//    
//    // MARK: Properties
//    
//    var weatherIcon: Int
//    let weatherText: String
//    
//    let temperatureCelsius: Int
//    let temperatureFahrenheit: Int
//    
//    // MARK: Initializers
//    
//    init(weatherIcon: Int, weatherText: String, temperatureCelsius: Int) {
//        self.weatherIcon = weatherIcon
//        self.weatherText = weatherText
//        self.temperatureCelsius = temperatureCelsius
//        self.temperatureFahrenheit = Manager.shared.fahrenheitFromCelsius(temperatureCelsius)
//    }
//    
//    // MARK: Codable
//    
//    public enum CodingKeys: CodingKey {
//        case weatherIcon, weatherText, temperatureCelsius, temperatureFahrenheit
//    }
//    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.weatherIcon = try container.decode(Int.self, forKey: .weatherIcon)
//        self.weatherText = try container.decode(String.self, forKey: .weatherText)
//        self.temperatureCelsius = try container.decode(Int.self, forKey: .temperatureCelsius)
//        self.temperatureFahrenheit = try container.decode(Int.self, forKey: .temperatureFahrenheit)
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.weatherIcon, forKey: .weatherIcon)
//        try container.encode(self.weatherText, forKey: .weatherText)
//        try container.encode(self.temperatureCelsius, forKey: .temperatureCelsius)
//        try container.encode(self.temperatureFahrenheit, forKey: .temperatureFahrenheit)
//    }
//}
