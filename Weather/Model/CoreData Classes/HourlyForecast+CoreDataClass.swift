import Foundation
import CoreData


public class HourlyForecast: WeatherInfo {
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(for city: City, forecastTime: Date, temperatureCelsius: Double, weatherIcon: Int, weatherText: String) {
        super.init(for: city,
                   temperatureCelsius: temperatureCelsius,
                   weatherIcon: weatherIcon,
                   weatherText: weatherText,
                   entityName: "HourlyForecast")        
        self.forecastTime = forecastTime
    }
}
