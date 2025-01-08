import Foundation
import CoreData


public class DailyForecast: NSManagedObject, DailyForecastProviding, CityManagedEntity {    
    
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
    
    convenience init?(for context: NSManagedObjectContext, data: [String : Any]) {
        
        let temperatureDictionary = data[String(.temperature)] as? [String : Any]
        let temperatureMinimumDictionary = temperatureDictionary?[String(.minimum)] as? [String : Any]
        let temperatureMaximumDictionary = temperatureDictionary?[String(.maximum)] as? [String : Any]
        guard let temperatureMinimumValue = temperatureMinimumDictionary?[String(.temperatureValue)] as? Double else { return nil }
        guard let temperatureMaximumValue = temperatureMaximumDictionary?[String(.temperatureValue)] as? Double else { return nil }
        
        let dayDictionary = data[String(.day)] as? [String : Any]
        guard let dayIcon = dayDictionary?[String(.dailyForecastWeatherIcon)] as? Int else { return nil }
        guard let dayText = dayDictionary?[String(.forecastWeatherText)] as? String else { return nil }
        
        let nightDictionary = data[String(.night)] as? [String : Any]
        guard let nightIcon = nightDictionary?[String(.dailyForecastWeatherIcon)] as? Int else { return nil }
        guard let nightText = nightDictionary?[String(.forecastWeatherText)] as? String else { return nil }
        
        guard let epochDate = data[String(.dailyDate)] as? TimeInterval else { return nil }
        let date = Date(timeIntervalSince1970: epochDate)
        
        self.init(for: context,
                  forecastDate: date,
                  dayTemperatureCelsius: temperatureMaximumValue,
                  dayWeatherIcon: dayIcon,
                  dayWeatherText: dayText,
                  nightTemperatureCelsius: temperatureMinimumValue,
                  nightWeatherIcon: nightIcon,
                  nightWeatherText: nightText)
    }
}
