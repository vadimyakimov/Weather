import Foundation
import UIKit
import CoreLocation
import CoreData

class NetworkManager {
    
    var city: City?
    
    //MARK: API keys
    
    lazy var keyAccuAPI = APIKeys().getRandomAPIKey()
    
    let baseURL = "https://dataservice.accuweather.com"
    let language = "language=" + "en-us".localized()
    
    let keyCityName = "LocalizedName"
    let keyCityID = "Key"
    
    let keyIsDayTime = "IsDayTime"
    let keyWeatherIcon = "WeatherIcon"
    let keyWeatherText = "WeatherText"
    let keyForecastWeatherText = "IconPhrase"
    let keyDailyForecastWeatherIcon = "Icon"
    
    let keyTemperature = "Temperature"
    let keyTemperatureValue = "Value"
    let keyCelsius = "Metric"
    
    let keyMinimum = "Minimum"
    let keyMaximum = "Maximum"
    
    let keyDay = "Day"
    let keyNight = "Night"
    
    let keyDailyForecast = "DailyForecasts"
    
    let keyHourlyDate = "EpochDateTime"
    let keyDailyDate = "EpochDate"
    
    // MARK: - Initializers
    
    init(city: City) {
        self.city = city
    }
    
    init() {
        self.city = nil
    }
    
    // MARK: - Server connection functions
    
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
        
    func getCurrentWeather(for id: String, complete: @escaping(CurrentWeather?) -> ()) {
                
        let url = "\(self.baseURL)/currentconditions/v1/\(id)?apikey=\(self.keyAccuAPI)&\(self.language)"
        
        self.fetchRequest(with: url) { data in
            let currentWeather = self.parseCurrentWearher(from: data)
            DispatchQueue.main.async {
                complete(currentWeather)
            }
        }
    }
    
    func getHourlyForecast(for id: String, complete: @escaping([HourlyForecast]?) -> ()) {
                
        let url = "\(self.baseURL)/forecasts/v1/hourly/12hour/\(id)?apikey=\(self.keyAccuAPI)&\(language)&metric=true"
        
        self.fetchRequest(with: url) { data in
            let hourlyForecast = self.parseHourlyForecast(from: data)
            DispatchQueue.main.async {
                complete(hourlyForecast)
            }
        }
    }
    
    func getDailyForecast(for id: String, complete: @escaping([DailyForecast]?) -> ()) {
                
        let url = "\(self.baseURL)/forecasts/v1/daily/5day/\(id)?apikey=\(self.keyAccuAPI)&\(language)&metric=true"
        
        self.fetchRequest(with: url) { data in
            let dailyForecast = self.parseDailyForecast(from: data)
            DispatchQueue.main.async {
                complete(dailyForecast)
            }
        }
    }
    
    func autocomplete(for text: String, complete: @escaping ([City]) -> ()) {
        guard let encodedText = (text as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            
        let url = "\(self.baseURL)/locations/v1/cities/autocomplete?apikey=\(self.keyAccuAPI)&q=\(encodedText)&\(self.language)"
        
        self.fetchRequest(with: url) { data in
            guard let parsedCityArray = self.parseCityAutocompleteArray(from: data) else { return }
            DispatchQueue.main.async {
                complete(parsedCityArray)
            }
        }
    }
    
    func geopositionCity(for location: CLLocationCoordinate2D, complete: @escaping (City) -> ()) {
        let url = "\(self.baseURL)/locations/v1/cities/geoposition/search?apikey=\(self.keyAccuAPI)&q=\(location.latitude),\(location.longitude)&\(self.language)"
                
        self.fetchRequest(with: url) { data in
            guard let parsedCity = self.parseGeopositionCity(from: data) else { return }
            DispatchQueue.main.async {
                complete(parsedCity)
            }
        }
        
    }
    
    private func fetchRequest(with urlString: String, complete: @escaping(Any?) -> ()) {
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { complete(nil) }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { complete(nil) }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            complete(jsonData)
        }
        
        task.resume()
    }
    
    //MARK: - Parsing functions
        
    private func parseCurrentWearher(from data: Any?) -> CurrentWeather? {
        
        guard let city = city,
              let dataDictionary = (data as? [[String : Any]])?.first else { return nil }
        
        let temperatureDictionary = dataDictionary[self.keyTemperature] as? [String:Any]
        let temperatureCelsiusDictionary = temperatureDictionary?[self.keyCelsius] as? [String:Any]
        guard let temperatureCelsius = temperatureCelsiusDictionary?[self.keyTemperatureValue] as? Double else { return nil }
        
        guard let isDayTime = dataDictionary[self.keyIsDayTime] as? Bool else { return nil }
        guard let weatherIcon = dataDictionary[self.keyWeatherIcon] as? Int else { return nil }
        guard let weatherText = dataDictionary[self.keyWeatherText] as? String else { return nil }
        
        let currentWeather = CurrentWeather(for: city,
                                            isDayTime: isDayTime,
                                            temperatureCelsius: temperatureCelsius,
                                            weatherIcon: weatherIcon,
                                            weatherText: weatherText)
        return currentWeather
    }
    
    private func parseHourlyForecast(from data: Any?) -> [HourlyForecast]? {
        
        guard let city = city,
              let dataArray = data as? [[String : Any]] else { return nil }
        
        var hourlyForecastArray: [HourlyForecast] = []
        
        for dataDictionary in dataArray {
            let temperatureDictionary = dataDictionary[self.keyTemperature] as? [String:Any]
            guard let temperatureCelsius = temperatureDictionary?[self.keyTemperatureValue] as? Double else { return nil }
            guard let weatherIcon = dataDictionary[self.keyWeatherIcon] as? Int else { return nil }
            guard let weatherText = dataDictionary[self.keyForecastWeatherText] as? String else { return nil }
            guard let epochDate = dataDictionary[self.keyHourlyDate] as? TimeInterval else { return nil }
            let date = Date(timeIntervalSince1970: epochDate)
            
            let hourlyForecastItem = HourlyForecast(for: city,
                                                       forecastTime: date,
                                                       temperatureCelsius: temperatureCelsius,
                                                       weatherIcon: weatherIcon,
                                                       weatherText: weatherText)
            hourlyForecastArray.append(hourlyForecastItem)
        }
        return hourlyForecastArray
    }
    
    private func parseDailyForecast(from data: Any?) -> [DailyForecast]? {
        
        guard let city = city,
              let dataArray = (data as? [String : Any])?[self.keyDailyForecast] as? [[String : Any]] else { return nil }
        
        var dailyForecastArray: [DailyForecast] = []
        
        for dataDictionary in dataArray {
            let temperatureDictionary = dataDictionary[self.keyTemperature] as? [String : Any]
            let temperatureMinimumDictionary = temperatureDictionary?[self.keyMinimum] as? [String : Any]
            let temperatureMaximumDictionary = temperatureDictionary?[self.keyMaximum] as? [String : Any]
            guard let temperatureMinimumValue = temperatureMinimumDictionary?[self.keyTemperatureValue] as? Double else { return nil }
            guard let temperatureMaximumValue = temperatureMaximumDictionary?[self.keyTemperatureValue] as? Double else { return nil }
            
            let dayDictionary = dataDictionary[self.keyDay] as? [String : Any]
            guard let dayIcon = dayDictionary?[self.keyDailyForecastWeatherIcon] as? Int else { return nil }
            guard let dayText = dayDictionary?[self.keyForecastWeatherText] as? String else { return nil }
            
            let nightDictionary = dataDictionary[self.keyNight] as? [String : Any]
            guard let nightIcon = nightDictionary?[self.keyDailyForecastWeatherIcon] as? Int else { return nil }
            guard let nightText = nightDictionary?[self.keyForecastWeatherText] as? String else { return nil }
            
            guard let epochDate = dataDictionary[self.keyDailyDate] as? TimeInterval else { return nil }
            let date = Date(timeIntervalSince1970: epochDate)
            
            let dailyForecastItem = DailyForecast(for: city,
                                                  forecastDate: date,
                                                  dayTemperatureCelsius: temperatureMaximumValue,
                                                  dayWeatherIcon: dayIcon,
                                                  dayWeatherText: dayText,
                                                  nightTemperatureCelsius: temperatureMinimumValue,
                                                  nightWeatherIcon: nightIcon,
                                                  nightWeatherText: nightText)
            
            dailyForecastArray.append(dailyForecastItem)
        }
        return dailyForecastArray
    }
    
    private func parseCityAutocompleteArray(from data: Any?) -> [City]? {
        
        guard let dataArray = data as? [[String : Any]] else { return nil }
        
        var autocompletedCitiesArray: [City] = []
        
        for dataDictionary in dataArray {
            if let key = dataDictionary[self.keyCityID] as? String,
               let name = dataDictionary[self.keyCityName] as? String {
                
                let city = City(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType),
                                key: key,
                                name: name)
                autocompletedCitiesArray.append(city)
            }
        }
        return autocompletedCitiesArray
    }
    
    private func parseGeopositionCity(from data: Any?) -> City? {
        
        guard let dataDictionary = data as? [String : Any] else { return nil }
        guard let key = dataDictionary[self.keyCityID] as? String else { return nil }
        guard let name = dataDictionary[self.keyCityName] as? String else { return nil }
        
        let city = City(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType),
                        key: key,
                        name: name,
                        isLocated: true)
        
        return city
    }    
}
