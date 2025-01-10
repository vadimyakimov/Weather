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
    
    private let networkManager: WeatherProviding
    private let context: NSManagedObjectContext
    
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
    
    init(city: CityDataProviding, networkManager: WeatherProviding, context: NSManagedObjectContext) {
        self.city = city
        self.networkManager = networkManager
        self.context = context
        
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
    
    // MARK: - Fetching data from network
     
    private func fetchCurrentWeather() async {
        if let currentWeather = await self.networkManager.getCurrentWeather(by: self.city.key) {
            self.updateData(currentWeather)
        }
    }
    
    private func fetchHourlyForecast() async {
        if let hourlyForecast = await self.networkManager.getHourlyForecast(by: self.city.key) {
            self.updateData(hourlyForecast)
        }
    }
    
    private func fetchDailyForecast() async {
        if let dailyForecast = await self.networkManager.getDailyForecast(by: self.city.key) {
            self.updateData(dailyForecast)
        }
    }
    
    // MARK: - CRUD
    
    private func updateData(_ data: CurrentWeatherProviding) {
        
        self.safePerformAndSave {
            
            let city = try? self.context.existingObject(with: self.city.objectID) as? CityDataProviding
            
            self.delete(object: city?.currentWeather)
            
            self.currentWeather.value = data
            (self.currentWeather.value as? CityManagedEntity)?.city = city as? City
            
            city?.lastUpdated.currentWeather = Date()
        } completion: {
            Task { [unowned self] in
                await self.delegate?.weatherInfoViewDidUpdateCurrentWeather()
            }
        }
        
    }
    
    private func updateData(_ data: [HourlyForecastProviding]) {
        
        self.safePerformAndSave {
            
            let city = try? self.context.existingObject(with: self.city.objectID) as? CityDataProviding
            
            if let array = city?.hourlyForecast?.array, !array.isEmpty {
                array.forEach({ self.delete(object: $0) })
            }
            
            self.hourlyForecast.value = data
            self.hourlyForecast.value?.forEach { ($0 as? CityManagedEntity)?.city = city as? City }
            
            city?.lastUpdated.hourlyForecast = Date()
        }
    }
    
    private func updateData(_ data: [DailyForecastProviding]) {
        
        self.safePerformAndSave {
            
            let city = try? self.context.existingObject(with: self.city.objectID) as? CityDataProviding
            
            if let array = city?.dailyForecast?.array, !array.isEmpty {
                array.forEach({ self.delete(object: $0) })
            }
            
            self.dailyForecast.value = data
            self.dailyForecast.value?.forEach { ($0 as? CityManagedEntity)?.city = city as? City }
            
            city?.lastUpdated.dailyForecast = Date()
            
        }
    }
    
    private func safePerformAndSave(block: @escaping () -> Void,
                                    completion: (() -> Void)? = nil) {
                
        self.context.perform {
            
            block()
            
            do {
                try self.context.save()
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
    
    private func delete(object: Any?) {
        guard let object = object as? NSManagedObject else { return }
        self.context.delete(object)
    }
    
}
