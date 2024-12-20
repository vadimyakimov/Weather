import Foundation
import CoreData


class CitiesCoreDataStack {
        
    // MARK: - Core Data stack
    
    static let shared = CitiesCoreDataStack()

    private var containerName = "Cities"
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.containerName)
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
    
    private init() {
        self.tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.tempContext.parent = self.context
    }

    // MARK: - Core Data context funcs
    
//    func safeModification(_ closure: @escaping() -> ()) {
//        
//        self.context.performAndWait {
//            closure()
//            self.saveContext()
//        }
//                
//    }

//    func saveContext () {
//        if self.context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
    
}
