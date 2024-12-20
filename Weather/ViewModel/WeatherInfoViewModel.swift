//
//  WeatherInfoViewModel.swift
//  Weather
//
//  Created by Вадим on 05.12.2024.
//

import Foundation
import UIKit
import CoreData

class WeatherInfoViewModel {
    
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
    
    // MARK: - Initializers
    
    init(city: City) {
        self.city = city
        
        self.currentWeather = Bindable(city.currentWeather)
        self.hourlyForecast = Bindable(city.hourlyForecast?.array as? [HourlyForecast])
        self.dailyForecast = Bindable(city.dailyForecast?.array as? [DailyForecast])
    }
    
    // MARK: - Funcs
    
    func refreshWeather(isForcedUpdate: Bool = false) {
                
        let lastUpdated = self.city.lastUpdated
        let tasks = DispatchGroup()
        
        if lastUpdated.currentWeather.timeIntervalSinceNow < -self.refreshTimeout || isForcedUpdate {
            tasks.enter()
            self.fetchCurrentWeather(dispatchGroup: tasks)
        }
        
        if lastUpdated.hourlyForecast.timeIntervalSinceNow < -self.refreshTimeout || isForcedUpdate {
            tasks.enter()
            self.fetchHourlyForecast(dispatchGroup: tasks)
        }

        if lastUpdated.dailyForecast.timeIntervalSinceNow < -self.refreshTimeout || isForcedUpdate {
            tasks.enter()
            self.fetchDailyForecast(dispatchGroup: tasks)
        }
        
        tasks.notify(queue: .main) {
            self.delegate?.weatherInfoView(didUpdateWeatherInfoFor: self.city)
        }
    }
    
    // MARK: - Fetching data from network
    
    func fetchCurrentWeather(dispatchGroup: DispatchGroup? = nil) {
        NetworkManager.shared.getCurrentWeather(for: self.city) { currentWeather in
            if let currentWeather = currentWeather {
                self.updateData(currentWeather)
            }
            dispatchGroup?.leave()
        }
    }
    
    func fetchHourlyForecast(dispatchGroup: DispatchGroup? = nil) {
        NetworkManager.shared.getHourlyForecast(for: self.city) { hourlyForecast in
            if let hourlyForecast = hourlyForecast {
                self.updateData(hourlyForecast)
            }
            dispatchGroup?.leave()
        }
    }
    
    func fetchDailyForecast(dispatchGroup: DispatchGroup? = nil) {
        NetworkManager.shared.getDailyForecast(for: self.city) { dailyForecast in
            if let dailyForecast = dailyForecast {
                self.updateData(dailyForecast)
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
    
    func updateData(_ data: CurrentWeather) {
        
        self.currentWeather.value = data
        self.currentWeather.value?.city = self.city
        
        self.city.lastUpdated.currentWeather = Date()
        
        self.delegate?.weatherInfoView(didUpdateCurrentWeatherFor: self.city)
    }
    
    func updateData(_ data: [HourlyForecast]) {
        
        if let array = self.city.hourlyForecast?.array, !array.isEmpty {
            array.forEach({ self.delete(object: $0) })
        }
        
        self.hourlyForecast.value = data
        self.hourlyForecast.value?.forEach { $0.city = self.city }
        
        self.city.lastUpdated.hourlyForecast = Date()
        
        self.saveContext()
    }
    
    func updateData(_ data: [DailyForecast]) {
        
        if let array = self.city.dailyForecast?.array, !array.isEmpty {
            array.forEach({ self.delete(object: $0) })
        }
        
        self.dailyForecast.value = data
        self.dailyForecast.value?.forEach { $0.city = self.city }
        
        self.city.lastUpdated.dailyForecast = Date()
        
        self.saveContext()
    }
    
    private func saveContext() {
        do {
            try self.city.managedObjectContext?.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    private func delete(object: Any) {
        guard let object = object as? NSManagedObject else { return }
        self.city.managedObjectContext?.delete(object)
    }
    
}
