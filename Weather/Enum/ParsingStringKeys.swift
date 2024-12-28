//
//  Untitled.swift
//  Weather
//
//  Created by Вадим on 28.12.2024.
//

enum ParsingStringKeys: String {
    
    case isDayTime = "IsDayTime"
    case weatherIcon = "WeatherIcon"
    case weatherText = "WeatherText"
    case forecastWeatherText = "IconPhrase"
    case dailyForecastWeatherIcon = "Icon"

    case temperature = "Temperature"
    case temperatureValue = "Value"
    case celsius = "Metric"

    case minimum = "Minimum"
    case maximum = "Maximum"

    case day = "Day"
    case night = "Night"

    case hourlyDate = "EpochDateTime"
    case dailyDate = "EpochDate"
}
