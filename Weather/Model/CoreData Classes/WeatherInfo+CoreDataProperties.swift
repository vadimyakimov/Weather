import Foundation
import CoreData


extension WeatherInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherInfo> {
        return NSFetchRequest<WeatherInfo>(entityName: String(WeatherInfo.self))
    }

    @NSManaged public var temperatureCelsius: Int16
    @NSManaged public var temperatureFahrenheit: Int16
    @NSManaged public var weatherIcon: Int16
    @NSManaged public var weatherText: String
    @NSManaged public var dayDailyForecast: DailyForecast?
    @NSManaged public var nightDailyForecast: DailyForecast?

}
