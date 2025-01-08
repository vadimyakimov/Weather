import CoreData

class CitiesCoreDataStack {
        
    // MARK: - Core Data stack
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: String(.coreDataContainerName))
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
        
    lazy var context: NSManagedObjectContext = {
        self.persistentContainer.viewContext
    }()

    lazy var tempContext: NSManagedObjectContext = {
        let tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        tempContext.parent = self.context
        return tempContext
    }()
    
}
