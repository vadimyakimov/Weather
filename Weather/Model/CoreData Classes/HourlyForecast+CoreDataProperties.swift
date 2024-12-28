import Foundation
import CoreData


extension HourlyForecast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HourlyForecast> {
        return NSFetchRequest<HourlyForecast>(entityName: String(HourlyForecast.self))
    }

    @NSManaged public var forecastTime: Date
    @NSManaged public var city: City?

}
