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
    
    init?(for city: City, data: Any?) {
        guard let dataDictionary = (data as? [[String : Any]])?.first else { return nil }

        let temperatureDictionary = dataDictionary[NetworkManager.shared.keyTemperature] as? [String:Any]
        let temperatureCelsiusDictionary = temperatureDictionary?[NetworkManager.shared.keyCelsius] as? [String:Any]
        guard let temperatureCelsius = temperatureCelsiusDictionary?[NetworkManager.shared.keyTemperatureValue] as? Double else { return nil }

        guard let isDayTime = dataDictionary[NetworkManager.shared.keyIsDayTime] as? Bool else { return nil }
        guard let weatherIcon = dataDictionary[NetworkManager.shared.keyWeatherIcon] as? Int else { return nil }
        guard let weatherText = dataDictionary[NetworkManager.shared.keyWeatherText] as? String else { return nil }
                
        super.init(for: city,
                   temperatureCelsius: temperatureCelsius,
                   weatherIcon: weatherIcon,
                   weatherText: weatherText,
                   entityName: "CurrentWeather")
        self.isDayTime = isDayTime
    }

}
