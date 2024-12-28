//
//  Untitled.swift
//  Weather
//
//  Created by Вадим on 28.12.2024.
//

enum FetchingStringKeys: String {
    
    case baseURL = "https://dataservice.accuweather.com"
    
    case cityName = "LocalizedName"
    case cityID = "Key"
    
    case dailyForecast = "DailyForecasts"
}
