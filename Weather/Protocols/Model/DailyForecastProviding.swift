//
//  DailyForecastProviding.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//

import Foundation

protocol DailyForecastProviding {
    var forecastDate: Date { get }
    var dayWeather: WeatherInfo { get }
    var nightWeather: WeatherInfo { get }
}
