import Foundation
import CoreData


class CitiesCoreDataStack {
        
    // MARK: - Core Data stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: String(.coreDataContainerName))
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
        
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    let tempContext: NSManagedObjectContext
          
    // MARK: - Initializers
    
    init() {
        self.tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.tempContext.parent = self.context
    }
}
