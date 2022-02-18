//
//  CurrentWeather+CoreDataProperties.swift
//  
//
//  Created by Вадим on 18.02.2022.
//
//

import Foundation
import CoreData


extension CurrentWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentWeather> {
        return NSFetchRequest<CurrentWeather>(entityName: "CurrentWeather")
    }

    @NSManaged public var isDayTime: Bool
    @NSManaged public var city: City?

}
