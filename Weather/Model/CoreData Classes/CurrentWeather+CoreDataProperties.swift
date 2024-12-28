import Foundation
import CoreData


extension CurrentWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentWeather> {
        return NSFetchRequest<CurrentWeather>(entityName: String(CurrentWeather.self))
    }

    @NSManaged public var isDayTime: Bool
    @NSManaged public var city: City?

}
