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
        
    var citiesList: [City] {
        get {
            return self.fetchCities()
        }
    }
    
    // MARK: - Initializers
    
    private init() {
        self.tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.tempContext.parent = self.context
    }

    // MARK: - Core Data context funcs

    func saveContext () {
        if self.context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Core Data working with entities
    
    
    private func fetchCities() -> [City] {
        let fetchRequest = City.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(City.id), ascending: true)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch entities: \(error.localizedDescription)")
            return []
        }
        
//        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                                    managedObjectContext: coreDataStack.persistentContainer.viewContext,
//                                                    sectionNameKeyPath: nil,
//                                                    cacheName: nil)
//        do {
//            try controller.performFetch()
//        } catch {
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//        return controller.fetchedObjects ?? []
    }
    
    func addCity(_ city: City) {
                
        _ = City(context: self.context,
                 id: Int16(self.citiesList.count),
                 key: city.key,
                 name: city.name,
                 isLocated: city.isLocated)
        
        self.saveContext()
    }
    
    func deleteCity(at index: Int) {
        
        guard let city = self.citiesList[safe: index] else { return }
    
        let deleteFromContext = self.context.delete

        if let currentWeather = city.currentWeather {
            deleteFromContext(currentWeather)
        }
        if let hourlyForecast = city.hourlyForecast?.array as? [HourlyForecast] {
            for item in hourlyForecast {
                deleteFromContext(item)
            }
        }
        if let dailyForecast = city.dailyForecast?.array as? [DailyForecast] {
            for item in dailyForecast {
                deleteFromContext(item)
            }
        }
        deleteFromContext(city.lastUpdated)
        deleteFromContext(city)
        
        self.saveContext()
    }
    
    func moveCity(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }

        let sourceCity = self.citiesList[sourceIndex]

        if sourceIndex > destinationIndex {
            for index in destinationIndex...sourceIndex {
                let city = self.citiesList[index]
                city.id += 1
            }
        } else if sourceIndex < destinationIndex {
            for index in sourceIndex...destinationIndex {
                let city = self.citiesList[index]
                city.id -= 1
            }
        }

        sourceCity.id = Int16(destinationIndex)
        
        self.saveContext()
    }
    
}
