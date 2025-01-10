//
//  CityViewModelProtocol.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//


protocol CityViewModelProtocol: WeatherInfoViewModelCreator, DayTimeProviding {
    var cityName: String { get }
    var cityId: Int { get }
}