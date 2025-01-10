//
//  WeatherInfoViewModel.swift
//  Weather
//
//  Created by Вадим on 05.12.2024.
//

import Foundation
import UIKit
import CoreData

class WeatherInfoViewModel: NSObject, WeatherInfoViewModelProtocol {
    
    // MARK: - Properties
    
    weak var delegate: WeatherInfoViewDelegate?
    
    let dataLoader: JSONDataProviding
    let APIKey: String
    
    private let city: CityDataProviding
    
    let currentWeather: Bindable<CurrentWeatherProviding?>
    let hourlyForecast: Bindable<[HourlyForecastProviding]?>
    let dailyForecast: Bindable<[DailyForecastProviding]?>
    
    private let refreshTimeout: TimeInterval = 600
    
    var isDayTime: Bool {
        self.city.currentWeather?.isDayTime ?? true
    }
    
    let isImperial: Bindable<Bool>
    
    // MARK: - Initializers
    
    init(city: CityDataProviding, dataLoader: JSONDataProviding, APIKey: String) {
        self.city = city
        self.dataLoader = dataLoader
        self.APIKey = APIKey
        
        self.currentWeather = Bindable(city.currentWeather)
        self.hourlyForecast = Bindable(city.hourlyForecast?.array as? [HourlyForecastProviding])
        self.dailyForecast = Bindable(city.dailyForecast?.array as? [DailyForecastProviding])
        
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
   
    private func setupUserDefaultsObservers() {
        UserDefaults.standard.addObserver(self, forKeyPath: String(.temperatureUnitSetting), options: [.new], context: nil)
    }
    
    func refreshWeather(isForcedUpdate: Bool) {
        
        let lastUpdated = self.city.lastUpdated
        
        Task { [unowned self] in
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
            await self.delegate?.weatherInfoViewDidFinishUpdating()
        }
    }
    
    func createNetworkManagerWithNewContext() -> (WeatherProviding, NSManagedObjectContext) {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = self.city.managedObjectContext
        let dataParser = ParsingManager(context: backgroundContext)
        let networkManager = NetworkManager(dataParser: dataParser, dataLoader: self.dataLoader, APIKey: self.APIKey)
        return (networkManager, backgroundContext)
    }
    
    // MARK: - Fetching data from network
     
    private func fetchCurrentWeather() async {
        let (networkManager, context) = self.createNetworkManagerWithNewContext()
        if let currentWeather = await networkManager.getCurrentWeather(by: self.city.key) {
            self.updateData(currentWeather, context: context)
        }
    }
    
    private func fetchHourlyForecast() async {
        let (networkManager, context) = self.createNetworkManagerWithNewContext()
        if let hourlyForecast = await networkManager.getHourlyForecast(by: self.city.key) {
            self.updateData(hourlyForecast, context: context)
        }
    }
    
    private func fetchDailyForecast() async {
        let (networkManager, context) = self.createNetworkManagerWithNewContext()
        if let dailyForecast = await networkManager.getDailyForecast(by: self.city.key) {
            self.updateData(dailyForecast, context: context)
        }
    }
    
    // MARK: - CRUD
    
    private func updateData(_ data: CurrentWeatherProviding, context: NSManagedObjectContext) {
        
        self.safePerformAndSave(at: context) {
            
            let city = try? context.existingObject(with: self.city.objectID) as? CityDataProviding
            
            self.delete(object: city?.currentWeather, at: context)
            
            self.currentWeather.value = data
            (self.currentWeather.value as? CityManagedEntity)?.city = city as? City
            
            city?.lastUpdated.currentWeather = Date()
        } completion: {
            Task { [unowned self] in
                await self.delegate?.weatherInfoViewDidUpdateCurrentWeather()
            }
        }
        
    }
    
    private func updateData(_ data: [HourlyForecastProviding], context: NSManagedObjectContext) {
        
        self.safePerformAndSave(at: context) {
            
            let city = try? context.existingObject(with: self.city.objectID) as? CityDataProviding
            
            if let array = city?.hourlyForecast?.array, !array.isEmpty {
                array.forEach({ self.delete(object: $0, at: context) })
            }
            
            self.hourlyForecast.value = data
            self.hourlyForecast.value?.forEach { ($0 as? CityManagedEntity)?.city = city as? City }
            
            city?.lastUpdated.hourlyForecast = Date()
        }
    }
    
    private func updateData(_ data: [DailyForecastProviding], context: NSManagedObjectContext) {
        
        self.safePerformAndSave(at: context) {
            
            let city = try? context.existingObject(with: self.city.objectID) as? CityDataProviding
            
            if let array = city?.dailyForecast?.array, !array.isEmpty {
                array.forEach({ self.delete(object: $0, at: context) })
            }
            
            self.dailyForecast.value = data
            self.dailyForecast.value?.forEach { ($0 as? CityManagedEntity)?.city = city as? City }
            
            city?.lastUpdated.dailyForecast = Date()
            
        }
    }
    
    private func safePerformAndSave(at context: NSManagedObjectContext,
                                    block: @escaping () -> Void,
                                    completion: (() -> Void)? = nil) {
                
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
