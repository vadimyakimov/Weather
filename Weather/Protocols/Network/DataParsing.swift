//
//  DataParsing.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//


protocol DataParsing {
    func parseCurrentWeather(from data: Any?) throws -> CurrentWeatherProviding
    func parseHourlyForecast(from data: Any?) throws -> [HourlyForecastProviding]
    func parseDailyForecast(from data: Any?) throws -> [DailyForecastProviding]
    
    func parseCityAutocompleteArray(from data: Any?) -> [CityDataProviding]?
    func parseGeopositionCity(from data: Any?) -> CityDataProviding?
}
