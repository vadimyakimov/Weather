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
    
    let isImperial: Bindable<Bool>
    
    // MARK: - Initializers
    
    init(city: City) {
        self.city = city
        
        self.currentWeather = Bindable(city.currentWeather)
        self.hourlyForecast = Bindable(city.hourlyForecast?.array as? [HourlyForecast])
        self.dailyForecast = Bindable(city.dailyForecast?.array as? [DailyForecast])
        
        let isImperial = UserDefaults.standard.bool(forKey: String(.temperatureUnitSetting))
        self.isImperial = Bindable(isImperial)
        
        super.init()
        
        self.setupUserDefaultsObservers()
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: String(.temperatureUnitSetting))
    }
    
    // MARK: - Funcs
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        if keyPath == String(.temperatureUnitSetting),
           let newValue = change?[.newKey] as? Bool {
            self.isImperial.value = newValue
        }
    }
   
    func setupUserDefaultsObservers() {
        UserDefaults.standard.addObserver(self, forKeyPath: String(.temperatureUnitSetting), options: [.new], context: nil)
    }
    
    func refreshWeather(isForcedUpdate: Bool = false) {
        
        let lastUpdated = self.city.lastUpdated
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                if lastUpdated.currentWeather.timeIntervalSinceNow < -self.refreshTimeout || isForcedUpdate {
                    group.addTask {
                        await self.fetchCurrentWeather()
                    }
                }
        
                if lastUpdated.hourlyForecast.timeIntervalSinceNow < -self.refreshTimeout || isForcedUpdate {
                    group.addTask {
                        await self.fetchHourlyForecast()
                    }
                }
        
                if lastUpdated.dailyForecast.timeIntervalSinceNow < -self.refreshTimeout || isForcedUpdate {
                    group.addTask {
                        await self.fetchDailyForecast()
                    }
                }
            }
        }
    }
    
    private func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.city.managedObjectContext
        return context
    }
    
    // MARK: - Fetching data from network
    
    func fetchCurrentWeather() async {
        let backgroundContext = self.newBackgroundContext()
        
        if let currentWeather = await NetworkManager.shared.getCurrentWeather(by: self.city.key, for: backgroundContext) {
            self.updateData(currentWeather, context: backgroundContext)
        }
    }
    
    func fetchHourlyForecast() async {
        let backgroundContext = self.newBackgroundContext()
        
        if let hourlyForecast = await NetworkManager.shared.getHourlyForecast(by: self.city.key, for: backgroundContext) {
            self.updateData(hourlyForecast, context: backgroundContext)
        }
    }
    
    func fetchDailyForecast() async {
        let backgroundContext = self.newBackgroundContext()
        
        if let dailyForecast = await NetworkManager.shared.getDailyForecast(by: self.city.key, for: backgroundContext) {
            self.updateData(dailyForecast, context: backgroundContext)
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
