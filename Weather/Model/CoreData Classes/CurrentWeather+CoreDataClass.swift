import Foundation
import CoreData


public class CurrentWeather: WeatherInfo {
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(for city: City, isDayTime: Bool, temperatureCelsius: Double, weatherIcon: Int, weatherText: String) {
        super.init(for: city,
                   temperatureCelsius: temperatureCelsius,
                   weatherIcon: weatherIcon,
                   weatherText: weatherText,
                   entityName: "CurrentWeather")
        self.isDayTime = isDayTime
    }

}
