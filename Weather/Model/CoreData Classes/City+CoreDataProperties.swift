import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: String(City.self))
    }

    @NSManaged public var id: Int16
    @NSManaged public var isLocated: Bool
    @NSManaged public var key: String
    @NSManaged public var name: String
    @NSManaged public var currentWeather: CurrentWeather?
    @NSManaged public var dailyForecast: NSOrderedSet?
    @NSManaged public var hourlyForecast: NSOrderedSet?
    @NSManaged public var lastUpdated: LastUpdated

}

// MARK: Generated accessors for dailyForecast
extension City {

    @objc(insertObject:inDailyForecastAtIndex:)
    @NSManaged public func insertIntoDailyForecast(_ value: DailyForecast, at idx: Int)

    @objc(removeObjectFromDailyForecastAtIndex:)
    @NSManaged public func removeFromDailyForecast(at idx: Int)

    @objc(insertDailyForecast:atIndexes:)
    @NSManaged public func insertIntoDailyForecast(_ values: [DailyForecast], at indexes: NSIndexSet)

    @objc(removeDailyForecastAtIndexes:)
    @NSManaged public func removeFromDailyForecast(at indexes: NSIndexSet)

    @objc(replaceObjectInDailyForecastAtIndex:withObject:)
    @NSManaged public func replaceDailyForecast(at idx: Int, with value: DailyForecast)

    @objc(replaceDailyForecastAtIndexes:withDailyForecast:)
    @NSManaged public func replaceDailyForecast(at indexes: NSIndexSet, with values: [DailyForecast])

    @objc(addDailyForecastObject:)
    @NSManaged public func addToDailyForecast(_ value: DailyForecast)

    @objc(removeDailyForecastObject:)
    @NSManaged public func removeFromDailyForecast(_ value: DailyForecast)

    @objc(addDailyForecast:)
    @NSManaged public func addToDailyForecast(_ values: NSOrderedSet)

    @objc(removeDailyForecast:)
    @NSManaged public func removeFromDailyForecast(_ values: NSOrderedSet)

}

// MARK: Generated accessors for hourlyForecast
extension City {

    @objc(insertObject:inHourlyForecastAtIndex:)
    @NSManaged public func insertIntoHourlyForecast(_ value: HourlyForecast, at idx: Int)

    @objc(removeObjectFromHourlyForecastAtIndex:)
    @NSManaged public func removeFromHourlyForecast(at idx: Int)

    @objc(insertHourlyForecast:atIndexes:)
    @NSManaged public func insertIntoHourlyForecast(_ values: [HourlyForecast], at indexes: NSIndexSet)

    @objc(removeHourlyForecastAtIndexes:)
    @NSManaged public func removeFromHourlyForecast(at indexes: NSIndexSet)

    @objc(replaceObjectInHourlyForecastAtIndex:withObject:)
    @NSManaged public func replaceHourlyForecast(at idx: Int, with value: HourlyForecast)

    @objc(replaceHourlyForecastAtIndexes:withHourlyForecast:)
    @NSManaged public func replaceHourlyForecast(at indexes: NSIndexSet, with values: [HourlyForecast])

    @objc(addHourlyForecastObject:)
    @NSManaged public func addToHourlyForecast(_ value: HourlyForecast)

    @objc(removeHourlyForecastObject:)
    @NSManaged public func removeFromHourlyForecast(_ value: HourlyForecast)

    @objc(addHourlyForecast:)
    @NSManaged public func addToHourlyForecast(_ values: NSOrderedSet)

    @objc(removeHourlyForecast:)
    @NSManaged public func removeFromHourlyForecast(_ values: NSOrderedSet)

}
