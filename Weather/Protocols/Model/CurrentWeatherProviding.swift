//
//  CurrentWeatherProviding.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//


protocol CurrentWeatherProviding: WeatherInfoProviding {
    var isDayTime: Bool { get }
}