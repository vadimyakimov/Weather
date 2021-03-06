import Foundation
import CoreData


extension LastUpdated {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastUpdated> {
        return NSFetchRequest<LastUpdated>(entityName: "LastUpdated")
    }

    @NSManaged public var currentWeather: Date
    @NSManaged public var dailyForecast: Date
    @NSManaged public var hourlyForecast: Date
    @NSManaged public var city: City?

}
