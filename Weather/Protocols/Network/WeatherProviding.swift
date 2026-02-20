//
//  WeatherProviding.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//


protocol WeatherProviding {
    func getCurrentWeather(by cityKey: String) async throws -> CurrentWeatherProviding
    func getHourlyForecast(by cityKey: String) async throws -> [HourlyForecastProviding]
    func getDailyForecast(by cityKey: String) async throws -> [DailyForecastProviding]
}
