//
//  WeatherInfoViewModel.swift
//  Weather
//
//  Created by Вадим on 05.12.2024.
//

import Foundation
import UIKit

class WeatherInfoViewModel {
    
    // MARK: - Properties
    
    weak var delegate: WeatherInfoViewDelegate?
    
    private let city: City
    var isDayTime: Bool {
        return self.city.currentWeather?.isDayTime ?? true
    }
    
    var didUpdateCurrentWeather: ((CurrentWeather) -> ())?
    var didUpdateHourlyForecast: (([HourlyForecast]) -> ())?
    var didUpdateDailyForecast: (([DailyForecast]) -> ())?
    
    // MARK: - Initializers
    
    init(city: City) {
        self.city = city
    }
    
    // MARK: - Funcs
    
    func refreshWeather(isForcedUpdate: Bool = false) {
        
        let lastUpdated = self.city.lastUpdated
        let tasks = DispatchGroup()
        
        if lastUpdated.currentWeather.timeIntervalSinceNow < -600 || isForcedUpdate {
            tasks.enter()
            self.fetchCurrentWeather(dispatchGroup: tasks)
        }
        
        if lastUpdated.hourlyForecast.timeIntervalSinceNow < -600 || isForcedUpdate {
            tasks.enter()
            self.fetchHourlyForecast(dispatchGroup: tasks)
        }

        if lastUpdated.dailyForecast.timeIntervalSinceNow < -600 || isForcedUpdate {
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
    
    // MARK: - Sating data to Core Data
    
    func updateData(_ data: CurrentWeather) {
        self.city.currentWeather = data
        self.city.lastUpdated.currentWeather = Date()
        self.delegate?.weatherInfoView(didUpdateCurrentWeatherFor: self.city)
        self.didUpdateCurrentWeather?(data)
    }
    
    func updateData(_ data: [HourlyForecast]) {
        self.city.hourlyForecast = NSOrderedSet(array: data)
        self.city.lastUpdated.hourlyForecast = Date()
        self.delegate?.weatherInfoView(didUpdateHourlyForecastFor: self.city)
        self.didUpdateHourlyForecast?(data)
    }
    
    func updateData(_ data: [DailyForecast]) {
        self.city.dailyForecast = NSOrderedSet(array: data)
        self.city.lastUpdated.dailyForecast = Date()
        self.delegate?.weatherInfoView(didUpdateDailyForecastFor: self.city)
        self.didUpdateDailyForecast?(data)
    }
    
}
