import Foundation
import CoreData


extension DailyForecast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyForecast> {
        return NSFetchRequest<DailyForecast>(entityName: String(DailyForecast.self))
    }

    @NSManaged public var forecastDate: Date
    @NSManaged public var city: City?
    @NSManaged public var dayWeather: WeatherInfo
    @NSManaged public var nightWeather: WeatherInfo

}
