//
//  WeatherInfoViewModel.swift
//  Weather
//
//  Created by Вадим on 05.12.2024.
//

import Foundation
import UIKit
import CoreData

class WeatherInfoViewModel: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: WeatherInfoViewDelegate?
    
    let city: City
    
    let currentWeather: Bindable<CurrentWeather?>
    let hourlyForecast: Bindable<[HourlyForecast]?>
    let dailyForecast: Bindable<[DailyForecast]?>
    
    let refreshTimeout: TimeInterval = 600
    
    var isDayTime: Bool {
        return self.city.currentWeather?.isDayTime ?? true
    }
    
    let isMetric: Bindable<Bool>
    
    // MARK: - Initializers
    
    init(city: City) {
        self.city = city
        
        self.currentWeather = Bindable(city.currentWeather)
        self.hourlyForecast = Bindable(city.hourlyForecast?.array as? [HourlyForecast])
        self.dailyForecast = Bindable(city.dailyForecast?.array as? [DailyForecast])
        
        let isMetric = UserDefaults.standard.bool(forKey: "is_metric")
        self.isMetric = Bindable(isMetric)
        
        super.init()
        
        self.setupUserDefaultsObservers()
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "is_metric")
    }
    
    // MARK: - Funcs
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        if keyPath == "is_metric",
           let newValue = change?[.newKey] as? Bool {
            self.isMetric.value = newValue
        }
    }
   
    func setupUserDefaultsObservers() {
        UserDefaults.standard.addObserver(self, forKeyPath: "is_metric", options: [.new], context: nil)
    }
    
    func refreshWeather(isForcedUpdate: Bool = false) {
        
        let lastUpdated = self.city.lastUpdated
        let tasks = DispatchGroup()
        
        //        if lastUpdated.currentWeather.timeIntervalSinceNow < -self.refreshTimeout || isForcedUpdate {
        //            self.fetchCurrentWeather(dispatchGroup: tasks)
        //        }
        //
        //        if lastUpdated.hourlyForecast.timeIntervalSinceNow < -self.refreshTimeout || isForcedUpdate {
        //            self.fetchHourlyForecast(dispatchGroup: tasks)
        //        }
        //
        //        if lastUpdated.dailyForecast.timeIntervalSinceNow < -self.refreshTimeout || isForcedUpdate {
        //            self.fetchDailyForecast(dispatchGroup: tasks)
        //        }
        
        tasks.notify(queue: .main) {
            self.delegate?.weatherInfoViewDidFinishUpdating()
        }
    }
    
    private func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.city.managedObjectContext
        return context
    }
    
    // MARK: - Fetching data from network
    
    func fetchCurrentWeather(dispatchGroup: DispatchGroup? = nil) {
        dispatchGroup?.enter()
        
        let backgroundContext = self.newBackgroundContext()
        
        NetworkManager.shared.getCurrentWeather(by: self.city.key, for: backgroundContext) { currentWeather in
            if let currentWeather = currentWeather {
                self.updateData(currentWeather, context: backgroundContext)
            }
            dispatchGroup?.leave()
        }
    }
    
    func fetchHourlyForecast(dispatchGroup: DispatchGroup? = nil) {
        dispatchGroup?.enter()
        
        let backgroundContext = self.newBackgroundContext()
        
        NetworkManager.shared.getHourlyForecast(by: self.city.key, for: backgroundContext) { hourlyForecast in
            if let hourlyForecast = hourlyForecast {
                self.updateData(hourlyForecast, context: backgroundContext)
            }
            dispatchGroup?.leave()
        }
    }
    
    func fetchDailyForecast(dispatchGroup: DispatchGroup? = nil) {
        dispatchGroup?.enter()
        
        let backgroundContext = self.newBackgroundContext()
        
        NetworkManager.shared.getDailyForecast(by: self.city.key, for: backgroundContext) { dailyForecast in
            if let dailyForecast = dailyForecast {
                self.updateData(dailyForecast, context: backgroundContext)
            }
            dispatchGroup?.leave()
        }
    }
    
    func fetchImage(iconNumber: Int16, completion: @escaping(UIImage) -> Void) {
        NetworkManager.shared.getImage(iconNumber: Int(iconNumber)) { weatherIcon in
            completion(weatherIcon)
        }
    }
    
    // MARK: - CRUD
    
    func updateData(_ data: CurrentWeather, context: NSManagedObjectContext) {
        
        self.safePerformAndSave(context) {
            
            let city = try? context.existingObject(with: self.city.objectID) as? City
            
            self.delete(object: city?.currentWeather, at: context)
            
            self.currentWeather.value = data
            self.currentWeather.value?.city = city
            
            city?.lastUpdated.currentWeather = Date()
        } completion: {
            self.delegate?.weatherInfoViewDidUpdateCurrentWeather()
        }
        
    }
    
    func updateData(_ data: [HourlyForecast], context: NSManagedObjectContext) {
        
        self.safePerformAndSave(context) {
            
            let city = try? context.existingObject(with: self.city.objectID) as? City
            
            if let array = city?.hourlyForecast?.array, !array.isEmpty {
                array.forEach({ self.delete(object: $0, at: context) })
            }
            
            self.hourlyForecast.value = data
            self.hourlyForecast.value?.forEach { $0.city = city }
            
            city?.lastUpdated.hourlyForecast = Date()
        }
    }
    
    func updateData(_ data: [DailyForecast], context: NSManagedObjectContext) {
        
        self.safePerformAndSave(context) {
            
            let city = try? context.existingObject(with: self.city.objectID) as? City
            
            if let array = city?.dailyForecast?.array, !array.isEmpty {
                array.forEach({ self.delete(object: $0, at: context) })
            }
            
            self.dailyForecast.value = data
            self.dailyForecast.value?.forEach { $0.city = city }
            
            city?.lastUpdated.dailyForecast = Date()
            
        }
    }
    
    private func safePerformAndSave(_ context: NSManagedObjectContext,
                                    block: @escaping () -> Void,
                                    completion: (() -> Void)? = nil) {
        
        guard context.parent == self.city.managedObjectContext else { return }
        
        context.perform {
            
            block()
            
            do {
                try context.save()
                self.city.managedObjectContext?.performAndWait {
                    do {
                        try self.city.managedObjectContext?.save()
                        completion?()
                    } catch {
                        let nserror = error as NSError
                        fatalError("Unresolved error while saving view context \(nserror), \(nserror.userInfo)")
                    }
                }
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error while saving background context \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func delete(object: Any?, at context: NSManagedObjectContext) {
        guard let object = object as? NSManagedObject else { return }
        context.delete(object)
    }
    
}
