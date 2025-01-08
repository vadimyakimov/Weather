import Foundation
import CoreData


public class WeatherInfo: NSManagedObject, WeatherInfoProviding {
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(for context: NSManagedObjectContext,
         temperatureCelsius: Double,
         weatherIcon: Int,
         weatherText: String,
         entityName: String = String(WeatherInfo.self)) {
                
        if let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) {
            super.init(entity: entity, insertInto: context)
        } else {
            super.init(context: context)
        }
        
        self.temperatureCelsius = Int16(round(temperatureCelsius))
        self.temperatureFahrenheit = self.fahrenheitFromCelsius(temperatureCelsius)
        self.weatherIcon = Int16(weatherIcon)
        self.weatherText = weatherText
    }
    
    private func fahrenheitFromCelsius(_ celsius: Double) -> Int16 {
        let fahrenheit = ((9 * celsius) / 5) + 32
        return Int16(round(fahrenheit))
    }
}
