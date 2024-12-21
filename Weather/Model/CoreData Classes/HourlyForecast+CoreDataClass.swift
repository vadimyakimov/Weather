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
        
        let temperatureDictionary = data[NetworkManager.shared.keyTemperature] as? [String:Any]
        guard let temperatureCelsius = temperatureDictionary?[NetworkManager.shared.keyTemperatureValue] as? Double else { return nil }
        guard let weatherIcon = data[NetworkManager.shared.keyWeatherIcon] as? Int else { return nil }
        guard let weatherText = data[NetworkManager.shared.keyForecastWeatherText] as? String else { return nil }
        guard let epochDate = data[NetworkManager.shared.keyHourlyDate] as? TimeInterval else { return nil }
        let date = Date(timeIntervalSince1970: epochDate)
        
        super.init(for: context,
                   temperatureCelsius: temperatureCelsius,
                   weatherIcon: weatherIcon,
                   weatherText: weatherText,
                   entityName: String(HourlyForecast.self))
        self.forecastTime = date
    }
}
