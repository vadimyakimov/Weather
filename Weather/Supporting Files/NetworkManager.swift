import Foundation
import UIKit
import CoreLocation
import CoreData

class NetworkManager {
        
    static let shared = NetworkManager()
    
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
    
    private init() {}
    
    // MARK: - Server connection functions
    
    func getImage(iconNumber: Int, complete: @escaping(UIImage) -> ()) {
                
        let numberFormatted = String(format: "%02d", iconNumber)
        let urlString = "https://developer.accuweather.com/sites/default/files/" + numberFormatted + "-s.png"
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url),
               let loadedImage = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    complete(loadedImage)
                }
            }
        }
    }
        
    func getCurrentWeather(for city: City, complete: @escaping(CurrentWeather?) -> ()) {
                
        let cityKey = city.key
        let url = "\(self.baseURL)/currentconditions/v1/\(cityKey)?apikey=\(self.keyAccuAPI)&\(self.language)"
        
        self.fetchRequest(with: url) { data in
            let currentWeather = CurrentWeather(for: city, data: data)
            DispatchQueue.main.async {
                complete(currentWeather)
            }
        }
    }
    
    func getHourlyForecast(for city: City, complete: @escaping([HourlyForecast]?) -> ()) {
        
        let cityKey = city.key
        let url = "\(self.baseURL)/forecasts/v1/hourly/12hour/\(cityKey)?apikey=\(self.keyAccuAPI)&\(language)&metric=true"
        
        self.fetchRequest(with: url) { data in
            let hourlyForecast = self.parseHourlyForecast(for: city, data: data)
            DispatchQueue.main.async {
                complete(hourlyForecast)
            }
        }
    }
    
    func getDailyForecast(for city: City, complete: @escaping([DailyForecast]?) -> ()) {
        
        let cityKey = city.key
        let url = "\(self.baseURL)/forecasts/v1/daily/5day/\(cityKey)?apikey=\(self.keyAccuAPI)&\(language)&metric=true"
        
        self.fetchRequest(with: url) { data in
            let dailyForecast = self.parseDailyForecast(for: city, data: data)
            DispatchQueue.main.async {
                complete(dailyForecast)
            }
        }
    }
    
    func autocomplete(for text: String, context: NSManagedObjectContext, complete: @escaping ([City]) -> ()) {
        guard let encodedText = (text as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            
        let url = "\(self.baseURL)/locations/v1/cities/autocomplete?apikey=\(self.keyAccuAPI)&q=\(encodedText)&\(self.language)"
        
        self.fetchRequest(with: url) { data in
            guard let parsedCityArray = self.parseCityAutocompleteArray(from: data, context: context) else { return }
            DispatchQueue.main.async {
                complete(parsedCityArray)
            }
        }
    }
    
    func geopositionCity(for location: CLLocationCoordinate2D, context: NSManagedObjectContext, complete: @escaping (City) -> ()) {
        let url = "\(self.baseURL)/locations/v1/cities/geoposition/search?apikey=\(self.keyAccuAPI)&q=\(location.latitude),\(location.longitude)&\(self.language)"
                
        self.fetchRequest(with: url) { data in
            guard let parsedCity = self.parseGeopositionCity(from: data, context: context) else { return }
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
       
    private func parseHourlyForecast(for city: City, data: Any?) -> [HourlyForecast]? {
        
        guard let dataArray = data as? [[String : Any]] else { return nil }
        
        var hourlyForecastArray: [HourlyForecast] = []
        
        for dataDictionary in dataArray {
            guard let hourlyForecastItem = HourlyForecast(for: city, data: dataDictionary) else { continue }
            hourlyForecastArray.append(hourlyForecastItem)
        }
        return hourlyForecastArray
    }
    
    private func parseDailyForecast(for city: City, data: Any?) -> [DailyForecast]? {
        
        guard let dataArray = (data as? [String : Any])?[self.keyDailyForecast] as? [[String : Any]] else { return nil }
        
        var dailyForecastArray: [DailyForecast] = []
        
        for dataDictionary in dataArray {
            guard let dailyForecastItem = DailyForecast(for: city, data: dataDictionary) else { continue }
            dailyForecastArray.append(dailyForecastItem)
        }
        return dailyForecastArray
    }
    
    private func parseCityAutocompleteArray(from data: Any?, context: NSManagedObjectContext) -> [City]? {
        
        guard let dataArray = data as? [[String : Any]] else { return nil }
        
        var autocompletedCitiesArray: [City] = []
        
        for dataDictionary in dataArray {
            if let key = dataDictionary[self.keyCityID] as? String,
               let name = dataDictionary[self.keyCityName] as? String {
                
                let city = City(context: context,
                                key: key,
                                name: name)
                autocompletedCitiesArray.append(city)
            }
        }
        return autocompletedCitiesArray
    }
    
    private func parseGeopositionCity(from data: Any?, context: NSManagedObjectContext) -> City? {
        
        guard let dataDictionary = data as? [String : Any] else { return nil }
        guard let key = dataDictionary[self.keyCityID] as? String else { return nil }
        guard let name = dataDictionary[self.keyCityName] as? String else { return nil }
        
        let city = City(context: context,
                        key: key,
                        name: name,
                        isLocated: true)
        
        return city
    }    
}
