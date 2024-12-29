import Foundation
import CoreData


public class HourlyForecast: WeatherInfo {
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(for context: NSManagedObjectContext,
         forecastTime: Date,
         temperatureCelsius: Double,
         weatherIcon: Int,
         weatherText: String) {
        
        super.init(for: context,
                   temperatureCelsius: temperatureCelsius,
                   weatherIcon: weatherIcon,
                   weatherText: weatherText,
                   entityName: String(HourlyForecast.self))
        self.forecastTime = forecastTime
    }
    
    init?(for context: NSManagedObjectContext, data: [String : Any]) {
        
        let temperatureDictionary = data[String(.temperature)] as? [String:Any]
        guard let temperatureCelsius = temperatureDictionary?[String(.temperatureValue)] as? Double else { return nil }
        guard let weatherIcon = data[String(.weatherIcon)] as? Int else { return nil }
        guard let weatherText = data[String(.forecastWeatherText)] as? String else { return nil }
        guard let epochDate = data[String(.hourlyDate)] as? TimeInterval else { return nil }
        let date = Date(timeIntervalSince1970: epochDate)
        
        super.init(for: context,
                   temperatureCelsius: temperatureCelsius,
                   weatherIcon: weatherIcon,
                   weatherText: weatherText,
                   entityName: String(HourlyForecast.self))
        self.forecastTime = date
    }
}
