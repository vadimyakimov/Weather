//
//  WeatherInfoProviding.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//


protocol WeatherInfoProviding {
    var temperatureCelsius: Int16 { get }
    var temperatureFahrenheit: Int16 { get }
    var weatherIcon: Int16 { get }
    var weatherText: String { get }
}