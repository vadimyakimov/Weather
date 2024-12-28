import Foundation
import CoreData


public class CurrentWeather: WeatherInfo {
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(for context: NSManagedObjectContext,
         isDayTime: Bool,
         temperatureCelsius: Double,
         weatherIcon: Int,
         weatherText: String) {
        
        super.init(for: context,
                   temperatureCelsius: temperatureCelsius,
                   weatherIcon: weatherIcon,
                   weatherText: weatherText,
                   entityName: String(CurrentWeather.self))
        self.isDayTime = isDayTime
    }
    
    init?(for context: NSManagedObjectContext, data: Any?) {
        
        guard let dataDictionary = (data as? [[String : Any]])?.first else { return nil }

        let temperatureDictionary = dataDictionary[String(.temperature)] as? [String:Any]
        let temperatureCelsiusDictionary = temperatureDictionary?[String(.celsius)] as? [String:Any]
        guard let temperatureCelsius = temperatureCelsiusDictionary?[String(.temperatureValue)] as? Double else { return nil }

        guard let isDayTime = dataDictionary[String(.isDayTime)] as? Bool else { return nil }
        guard let weatherIcon = dataDictionary[String(.weatherIcon)] as? Int else { return nil }
        guard let weatherText = dataDictionary[String(.weatherText)] as? String else { return nil }
                
        super.init(for: context,
                   temperatureCelsius: temperatureCelsius,
                   weatherIcon: weatherIcon,
                   weatherText: weatherText,
                   entityName: String(CurrentWeather.self))
        self.isDayTime = isDayTime
    }

}
