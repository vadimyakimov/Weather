//
//  WeatherInfo+CoreDataProperties.swift
//  
//
//  Created by Вадим on 18.02.2022.
//
//

import Foundation
import CoreData


extension WeatherInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherInfo> {
        return NSFetchRequest<WeatherInfo>(entityName: "WeatherInfo")
    }

    @NSManaged public var temperatureCelsius: Int16
    @NSManaged public var temperatureFahrenheit: Int16
    @NSManaged public var weatherIcon: Int16
    @NSManaged public var weatherText: String
    @NSManaged public var dayDailyForecast: DailyForecast?
    @NSManaged public var nightDailyForecast: DailyForecast?

}
