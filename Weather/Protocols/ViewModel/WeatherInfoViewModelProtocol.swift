//
//  WeatherInfoViewModelProtocol.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//


protocol WeatherInfoViewModelProtocol: AnyObject, DayTimeProviding {
    
    var currentWeather: Bindable<CurrentWeatherProviding?> { get }
    var hourlyForecast: Bindable<[HourlyForecastProviding]?> { get }
    var dailyForecast: Bindable<[DailyForecastProviding]?> { get }
    
    var isImperial: Bindable<Bool> { get }
    
    var delegate: WeatherInfoViewDelegate? { get set }
    
    func refreshWeather(isForcedUpdate: Bool)
}