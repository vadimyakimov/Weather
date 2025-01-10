//
//  CityDataProviding.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//

import CoreData

protocol CityDataProviding: NSManagedObject {
    var id: Int16 { get set }
    var isLocated: Bool { get }
    var key: String { get }
    var name: String { get }
    var currentWeather: CurrentWeather? { get }
    var dailyForecast: NSOrderedSet? { get }
    var hourlyForecast: NSOrderedSet? { get }
    var lastUpdated: LastUpdated { get }
}
