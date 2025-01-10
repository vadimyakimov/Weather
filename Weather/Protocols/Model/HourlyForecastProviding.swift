//
//  HourlyForecastProviding.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//

import Foundation

protocol HourlyForecastProviding: WeatherInfoProviding {
    var forecastTime: Date { get }
}
