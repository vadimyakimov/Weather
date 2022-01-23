//
//  Manager.swift
//  Weather 2
//
//  Created by Вадим on 12.01.2022.
//

import Foundation
import UIKit
import CoreLocation

class Manager {
    
    // MARK: - Properties
    
    static let shared = Manager()
    
    var citiesArray: [City] {
        get {
            if let data = UserDefaults.standard.data(forKey: self.keyCitiesArrayUserDefaults),
               let decoded = try? JSONDecoder().decode([City].self, from: data) {
                return decoded
            }
            
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: self.keyCitiesArrayUserDefaults)
            }
        }
    }
    
    var citiesAutocompleteArray: [CityAutocomplete] = []
    
    private let keyCitiesArrayUserDefaults = "CitiesArray"
    
    private let baseURL = "https://dataservice.accuweather.com"
    
    private let keyCityName = "LocalizedName"
    private let keyCityID = "Key"
    
    private let keyIsDayTime = "IsDayTime"
    private let keyWeatherIcon = "WeatherIcon"
    private let keyWeatherText = "WeatherText"
    private let keyForecastWeatherText = "IconPhrase"
    private let keyDailyForecastWeatherIcon = "Icon"
    
    private let keyTemperature = "Temperature"
    private let keyTemperatureValue = "Value"
    private let keyCelsius = "Metric"
    
    private let keyMinimum = "Minimum"
    private let keyMaximum = "Maximum"
    
    private let keyDay = "Day"
    private let keyNight = "Night"
    
    private let keyDailyForecast = "DailyForecasts"
    
    private let keyHourlyDate = "EpochDateTime"
    private let keyDailyDate = "EpochDate"
    
    private let keyAccuAPI = "aclG15Tu7dG0kikCCAYWL2TiCgNp6I6y"
    //pUPRp5bjAvEajZjEA6kc6yPSlbYMhXRZ
    //YyRHncuTlsidjyS4YVziEZPChV4sPDVA
    //dcXaSaOT2bTNKzDiMD37dnGlZXGEeTxG
    //WaP8kp90kGrPCypoU4Tp7mmQKcnG9YUe
    //aclG15Tu7dG0kikCCAYWL2TiCgNp6I6y
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public funcs
    
    func autocomplete(for text: String, complete: @escaping () -> ()) {
        let urlString = "\(self.baseURL)/locations/v1/cities/autocomplete?apikey=\(self.keyAccuAPI)&q=\(text)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let cityDataArray = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String : Any]]
            guard let parsedCityArray = self.parseCityAutocompleteArray(from: cityDataArray) else { return }
            self.citiesAutocompleteArray = parsedCityArray
            DispatchQueue.main.async {
                complete()
            }
        }.resume()
    }
    
    func geopositionCity(for location: CLLocationCoordinate2D, complete: @escaping () -> ()) {
        let urlString = "\(self.baseURL)/locations/v1/cities/geoposition/search?apikey=\(self.keyAccuAPI)&q=\(location.latitude),\(location.longitude)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let newCity = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]
            guard let parsedCity = self.parseGeopositionCity(from: newCity) else { return }
            if self.citiesArray.first?.isLocated == true {
                self.citiesArray.removeFirst()
            }
            self.citiesArray.insert(parsedCity, at: 0)
            DispatchQueue.main.async {
                complete()
            }
        }.resume()
    }
    
    func getCurrentWeather(for index: Int, complete: @escaping() -> () ) {
        let id = self.citiesArray[index].id
        let urlString = "\(self.baseURL)/currentconditions/v1/\(id)?apikey=\(self.keyAccuAPI)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let d = data, error == nil else { return }
            let currentWeather = try? JSONSerialization.jsonObject(with: d, options: .mutableContainers) as? [[String : Any]]
            guard let parsedCurrentWeather = self.parseCurrentWearher(from: currentWeather) else { return }
            let city = self.citiesArray[index]
            city.lastUpdated = Date()
            city.currentWeather = parsedCurrentWeather
            self.citiesArray[index] = city
            DispatchQueue.main.async {
                complete()
            }
        }.resume()
    }
    
    func getHourlyForecast(for index: Int, complete: @escaping() -> () ) {
        let id = self.citiesArray[index].id
        let urlString = "\(self.baseURL)/forecasts/v1/hourly/12hour/\(id)?apikey=\(self.keyAccuAPI)&metric=true"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let d = data, error == nil else { return }
            let hourlyForecastArray = try? JSONSerialization.jsonObject(with: d, options: .mutableContainers) as? [[String : Any]]
            guard let parsedHourlyForecastArray = self.parseHourlyForecastArray(from: hourlyForecastArray) else { return }
            let city = self.citiesArray[index]
            city.lastUpdated = Date()
            city.hourlyForecast = parsedHourlyForecastArray
            self.citiesArray[index] = city
            DispatchQueue.main.async {
                complete()
            }
        }.resume()
    }
    
    func getDailyForecast(for index: Int, complete: @escaping() -> () ) {
        let id = self.citiesArray[index].id
        let urlString = "\(self.baseURL)/forecasts/v1/daily/5day/\(id)?apikey=\(self.keyAccuAPI)&metric=true"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let d = data, error == nil else { return }
            let dailyForecastDictionary = try? JSONSerialization.jsonObject(with: d, options: .mutableContainers) as? [String : Any]
            guard let parsedDailyForecastDictionary = self.parseDailyForecastDictionary(from: dailyForecastDictionary) else { return }
            let city = self.citiesArray[index]
            city.lastUpdated = Date()
            city.dailyForecast = parsedDailyForecastDictionary
            self.citiesArray[index] = city
            DispatchQueue.main.async {
                complete()
            }  
        }.resume()
    }
    
    func getImage(iconNumber: Int, complete: @escaping(UIImage) -> ()) {
        
        let numberFormatted = String(format: "%02d", iconNumber)
        let urlString = "https://developer.accuweather.com/sites/default/files/" + numberFormatted + "-s.png"
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async { 
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                    DispatchQueue.main.async {                        
                        complete(loadedImage)
                    }
                }
            }
        }
    }
    
    func fahrenheitFromCelsius(_ celsius: Int) -> Int {
        let fahrenheit = ((9 * celsius) / 5) + 32
        return fahrenheit
    }
    
    
    // MARK: - Private funcs
    
    private func parseCityAutocompleteArray(from dataArray: [[String : Any]]?) -> [CityAutocomplete]? {
        guard let dataArray = dataArray else { return nil }
        var cityArray: [CityAutocomplete] = []
        for dataDictionary in dataArray {
            if let id = dataDictionary[self.keyCityID] as? String,
               let name = dataDictionary[self.keyCityName] as? String {
                cityArray.append(CityAutocomplete(id: id, name: name))
            }
        }
        return cityArray
    }
    
    private func parseGeopositionCity(from dataDictionary: [String : Any]?) -> City? {
        guard let dataDictionary = dataDictionary else { return nil }
        guard let id = dataDictionary[self.keyCityID] as? String else { return nil }
        guard let name = dataDictionary[self.keyCityName] as? String else { return nil }
        let newCity = City(id: id, name: name, isLocated: true)
        return newCity
    }
    
    private func parseCurrentWearher(from dataArray: [[String : Any]]?) -> CurrentWeather? {
        guard let dataDictionary = dataArray?.first else { return nil }
        
        let temperatureDictionary = dataDictionary[self.keyTemperature] as? [String:Any]
        let temperatureCelsiusDictionary = temperatureDictionary?[self.keyCelsius] as? [String:Any]
        guard let temperatureCelsius = temperatureCelsiusDictionary?[self.keyTemperatureValue] as? Double else { return nil }
        
        guard let isDayTime = dataDictionary[self.keyIsDayTime] as? Bool else { return nil }
        guard let weatherIcon = dataDictionary[self.keyWeatherIcon] as? Int else { return nil }
        guard let weatherText = dataDictionary[self.keyWeatherText] as? String else { return nil }
        
        let currentWeather = CurrentWeather(isDayTime: isDayTime,
                                            temperatureCelsius: Int(round(temperatureCelsius)),
                                            weatherIcon: weatherIcon,
                                            weatherText: weatherText)
        return currentWeather
    }
    
    private func parseHourlyForecastArray(from dataArray: [[String : Any]]?) -> [HourlyForecast]? {
        guard let dataArray = dataArray else { return nil }
        
        var hourlyForecastArray: [HourlyForecast] = []
        
        for dataDictionary in dataArray {
            let temperatureDictionary = dataDictionary[self.keyTemperature] as? [String:Any]
            guard let temperatureCelsius = temperatureDictionary?[self.keyTemperatureValue] as? Double else { return nil }
            guard let weatherIcon = dataDictionary[self.keyWeatherIcon] as? Int else { return nil }
            guard let weatherText = dataDictionary[self.keyForecastWeatherText] as? String else { return nil }
            guard let epochDate = dataDictionary[self.keyHourlyDate] as? TimeInterval else { return nil }
            let date = Date(timeIntervalSince1970: epochDate)
            
            
            
            hourlyForecastArray.append(HourlyForecast(forecastTime: date,
                                                      temperatureCelsius: Int(round(temperatureCelsius)),
                                                      weatherIcon: weatherIcon,
                                                      weatherText: weatherText))
        }
        return hourlyForecastArray
    }
    
    private func parseDailyForecastDictionary(from data: [String : Any]?) -> [DailyForecast]? {
        guard let dataArray = data?[self.keyDailyForecast] as? [[String : Any]] else { return nil }
        
        var dailyForecastArray: [DailyForecast] = []
        
        for dataDictionary in dataArray {
            let temperatureDictionary = dataDictionary[self.keyTemperature] as? [String : Any]
            let temperatureMinimumDictionary = temperatureDictionary?[self.keyMinimum] as? [String : Any]
            let temperatureMaximumDictionary = temperatureDictionary?[self.keyMaximum] as? [String : Any]
            guard let temperatureMinimumValueDictionary = temperatureMinimumDictionary?[self.keyTemperatureValue] as? Double else { return nil }
            guard let temperatureMaximumValueDictionary = temperatureMaximumDictionary?[self.keyTemperatureValue] as? Double else { return nil }
            
            let dayDictionary = dataDictionary[self.keyDay] as? [String : Any]
            guard let dayIcon = dayDictionary?[self.keyDailyForecastWeatherIcon] as? Int else { return nil }
            guard let dayText = dayDictionary?[self.keyForecastWeatherText] as? String else { return nil }
            
            let nightDictionary = dataDictionary[self.keyNight] as? [String : Any]
            guard let nightIcon = nightDictionary?[self.keyDailyForecastWeatherIcon] as? Int else { return nil }
            guard let nightText = nightDictionary?[self.keyForecastWeatherText] as? String else { return nil }
            
            guard let epochDate = dataDictionary[self.keyDailyDate] as? TimeInterval else { return nil }
            let date = Date(timeIntervalSince1970: epochDate)
            
            dailyForecastArray.append(DailyForecast(forecastDate: date,
                                                    temperatureCelsiusMinimum: Int(round(temperatureMinimumValueDictionary)),
                                                    temperatureCelsiusMaximum: Int(round(temperatureMaximumValueDictionary)),
                                                    dayWeatherIcon: dayIcon,
                                                    dayWeatherText: dayText,
                                                    nightWeatherIcon: nightIcon,
                                                    nightWeatherText: nightText))
        }
        return dailyForecastArray
    }
    
}
