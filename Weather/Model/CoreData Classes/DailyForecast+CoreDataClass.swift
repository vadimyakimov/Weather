import Foundation
import CoreData


public class DailyForecast: NSManagedObject {
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(for context: NSManagedObjectContext,
         forecastDate: Date,
         dayTemperatureCelsius: Double,
         dayWeatherIcon: Int,
         dayWeatherText: String,
         nightTemperatureCelsius: Double,
         nightWeatherIcon: Int,
         nightWeatherText: String) {
               
        if let entity = NSEntityDescription.entity(forEntityName: String(DailyForecast.self), in: context) {
            super.init(entity: entity, insertInto: context)
        } else {
            super.init(context: context)
        }
        
        self.forecastDate = forecastDate
                
        self.dayWeather = WeatherInfo(for: context,
                                      temperatureCelsius: dayTemperatureCelsius,
                                      weatherIcon: dayWeatherIcon,
                                      weatherText: dayWeatherText)
        
        self.nightWeather = WeatherInfo(for: context,
                                        temperatureCelsius: nightTemperatureCelsius,
                                        weatherIcon: nightWeatherIcon,
                                        weatherText: nightWeatherText)
    }
    
    init?(for context: NSManagedObjectContext, data: [String : Any]) {
        
        let temperatureDictionary = data[NetworkManager.shared.keyTemperature] as? [String : Any]
        let temperatureMinimumDictionary = temperatureDictionary?[NetworkManager.shared.keyMinimum] as? [String : Any]
        let temperatureMaximumDictionary = temperatureDictionary?[NetworkManager.shared.keyMaximum] as? [String : Any]
        guard let temperatureMinimumValue = temperatureMinimumDictionary?[NetworkManager.shared.keyTemperatureValue] as? Double else { return nil }
        guard let temperatureMaximumValue = temperatureMaximumDictionary?[NetworkManager.shared.keyTemperatureValue] as? Double else { return nil }
        
        let dayDictionary = data[NetworkManager.shared.keyDay] as? [String : Any]
        guard let dayIcon = dayDictionary?[NetworkManager.shared.keyDailyForecastWeatherIcon] as? Int else { return nil }
        guard let dayText = dayDictionary?[NetworkManager.shared.keyForecastWeatherText] as? String else { return nil }
        
        let nightDictionary = data[NetworkManager.shared.keyNight] as? [String : Any]
        guard let nightIcon = nightDictionary?[NetworkManager.shared.keyDailyForecastWeatherIcon] as? Int else { return nil }
        guard let nightText = nightDictionary?[NetworkManager.shared.keyForecastWeatherText] as? String else { return nil }
        
        guard let epochDate = data[NetworkManager.shared.keyDailyDate] as? TimeInterval else { return nil }
        let date = Date(timeIntervalSince1970: epochDate)
                
        if let entity = NSEntityDescription.entity(forEntityName: String(DailyForecast.self), in: context) {
            super.init(entity: entity, insertInto: context)
        } else {
            super.init(context: context)
        }
        
        self.forecastDate = date
                
        self.dayWeather = WeatherInfo(for: context,
                                      temperatureCelsius: temperatureMaximumValue,
                                      weatherIcon: dayIcon,
                                      weatherText: dayText)
        
        self.nightWeather = WeatherInfo(for: context,
                                        temperatureCelsius: temperatureMinimumValue,
                                        weatherIcon: nightIcon,
                                        weatherText: nightText)
    }
}
