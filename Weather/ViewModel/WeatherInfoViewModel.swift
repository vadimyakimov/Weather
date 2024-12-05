//
//  WeatherInfoViewModel.swift
//  Weather
//
//  Created by Вадим on 05.12.2024.
//

import Foundation

class WeatherInfoViewModel {
    
    weak var delegate: WeatherInfoViewDelegate?
    
    private let city: City
    
    var currentWeather: Bindable<CurrentWeather?> {
        return Bindable(self.city.currentWeather)
    }
    
    var hourlyForecast: Bindable<[HourlyForecast]?> {
        return Bindable(self.city.hourlyForecast?.array as? [HourlyForecast])
    }
    
    var dailyForecast: Bindable<[DailyForecast]?> {
        return Bindable(self.city.dailyForecast?.array as? [DailyForecast])
    }
    
    var isDayTime: Bool {
        return self.city.currentWeather?.isDayTime ?? true
    }
    
    var lastUpdated: LastUpdated {
        return self.city.lastUpdated
    }
    
    
    
    init(city: City) {
        self.city = city
    }
    
    func refreshWeather() {
        let tasks = DispatchGroup()
        
        tasks.enter()
        self.fetchCurrentWeather(dispatchGroup: tasks)
        
        tasks.enter()
        self.fetchHourlyForecast(dispatchGroup: tasks)
        
        tasks.enter()
        self.fetchDailyForecast(dispatchGroup: tasks)
        
        tasks.notify(queue: .main) {
            self.delegate?.weatherInfoView(didUpdateWeatherInfoFor: self.city)
        }
    }
    
    
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
                self.updateData(data: hourlyForecast)
            }
            dispatchGroup?.leave()
        }
    }
    
    func fetchDailyForecast(dispatchGroup: DispatchGroup? = nil) {
        NetworkManager.shared.getDailyForecast(for: self.city) { dailyForecast in
            if let dailyForecast = dailyForecast {
                self.updateData(data: dailyForecast)
            }
            dispatchGroup?.leave()
        }
    }
    
    func updateData(_ data: CurrentWeather) {
        self.city.currentWeather = data
        self.city.lastUpdated.currentWeather = Date()
        self.delegate?.weatherInfoView(didUpdateCurrentWeatherFor: self.city)
    }
    
     func updateData(data: [HourlyForecast]) {
        self.city.hourlyForecast = NSOrderedSet(array: data)
        self.city.lastUpdated.hourlyForecast = Date()
        self.delegate?.weatherInfoView(didUpdateHourlyForecastFor: self.city)
    }
    
     func updateData(data: [DailyForecast]) {
        self.city.dailyForecast = NSOrderedSet(array: data)
        self.city.lastUpdated.dailyForecast = Date()
        self.delegate?.weatherInfoView(didUpdateDailyForecastFor: self.city)
    }
    
}
