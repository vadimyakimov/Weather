////
////  DailyForecast.swift
////  Weather 2
////
////  Created by Вадим on 15.01.2022.
////
//
//import Foundation
//
//class ZDailyForecast: Codable {
//    
//    // MARK: Properties
//    
//    let forecastDate: Date
//    let dayWeather: WeatherInfo
//    let nightWeather: WeatherInfo
//    
//    // MARK: Initializers
//    
//    init(forecastDate: Date,
//         temperatureCelsiusMinimum: Int,
//         temperatureCelsiusMaximum: Int,
//         dayWeatherIcon: Int,
//         dayWeatherText: String,
//         nightWeatherIcon: Int,
//         nightWeatherText: String) {
//        
//        self.forecastDate = forecastDate
//        self.dayWeather = WeatherInfo(weatherIcon: dayWeatherIcon,
//                                      weatherText: dayWeatherText,
//                                      temperatureCelsius: temperatureCelsiusMaximum)
//        self.nightWeather = WeatherInfo(weatherIcon: nightWeatherIcon,
//                                        weatherText: nightWeatherText,
//                                        temperatureCelsius: temperatureCelsiusMinimum)
//    }
//    
//}
