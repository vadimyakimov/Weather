import Foundation
import CoreData


public class WeatherInfo: NSManagedObject {
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(for city: City, temperatureCelsius: Double, weatherIcon: Int, weatherText: String, entityName: String = "WeatherInfo") {
        
        let context = city.managedObjectContext!
        
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
    
    func fahrenheitFromCelsius(_ celsius: Double) -> Int16 {
        let fahrenheit = ((9 * celsius) / 5) + 32
        return Int16(round(fahrenheit))
    }
}
