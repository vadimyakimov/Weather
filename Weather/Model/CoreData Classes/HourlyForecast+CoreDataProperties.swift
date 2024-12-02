import Foundation
import CoreData


extension HourlyForecast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HourlyForecast> {
        return NSFetchRequest<HourlyForecast>(entityName: "HourlyForecast")
    }

    @NSManaged public var forecastTime: Date
    @NSManaged public var city: City?

}
