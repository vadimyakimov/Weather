import Foundation
import CoreData


public class City: NSManagedObject, CityDataProviding {
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(context: NSManagedObjectContext, id: Int16? = nil, key: String, name: String, isLocated: Bool = false) {
        
        if let cityEntity = NSEntityDescription.entity(forEntityName: String(City.self), in: context) {
            super.init(entity: cityEntity, insertInto: context)
        } else {
            super.init(context: context)
        }
        
        if let id {
            self.id = id
        }
        self.key = key
        self.name = name
        self.isLocated = isLocated
        
        if let lastUpdatedEntity = NSEntityDescription.entity(forEntityName: String(LastUpdated.self), in: context) {
            self.lastUpdated = LastUpdated(entity: lastUpdatedEntity, insertInto: context)
        } else {
            self.lastUpdated = LastUpdated(context: context)
        }
    }    
}
