import Foundation
import UIKit
import CoreLocation
import CoreData
import Kingfisher

class NetworkManager {
    
    static let shared = NetworkManager()
    
    //MARK: API keys
    
    let keyAccuAPI = APIKeys().getRandomAPIKey()
    
    let languageURLKey = "language=" + "en-us".localized()
       
    
    // MARK: - Initializers
    
    private init() {
        print(self.keyAccuAPI)
    }
    
    // MARK: - Server connection functions
    
    func getImage(_ iconNumber: Int) async -> UIImage? {
        
        let numberFormatted = String(format: "%02d", iconNumber)
        let urlString = "https://developer.accuweather.com/sites/default/files/\(numberFormatted)-s.png"
        guard let url = URL(string: urlString) else { return nil }
                
        do {
            let result = try await KingfisherManager.shared.retrieveImage(with: url)
            return result.image
        } catch {
            print("Error during getImage: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getCurrentWeather(by cityKey: String, for context: NSManagedObjectContext) async -> CurrentWeatherProviding? {
        
        let url = "\(String(.baseURL))/currentconditions/v1/\(cityKey)?apikey=\(self.keyAccuAPI)&\(self.languageURLKey)"
        
        let json = await self.getJSON(from: url)
        let currentWeather = CurrentWeather(for: context, data: json)
        
        return currentWeather
    }
    
    func getHourlyForecast(by cityKey: String, for context: NSManagedObjectContext) async -> [HourlyForecastProviding]? {
        
        let url = "\(String(.baseURL))/forecasts/v1/hourly/12hour/\(cityKey)?apikey=\(self.keyAccuAPI)&\(self.languageURLKey)&metric=true"
        
        let json = await self.getJSON(from: url)
        let hourlyForecast = self.parseHourlyForecast(for: context, data: json)
        return hourlyForecast
    }
    
    func getDailyForecast(by cityKey: String, for context: NSManagedObjectContext) async -> [DailyForecastProviding]? {
        
        let url = "\(String(.baseURL))/forecasts/v1/daily/5day/\(cityKey)?apikey=\(self.keyAccuAPI)&\(self.languageURLKey)&metric=true"
        
        let json = await self.getJSON(from: url)
        let dailyForecast = self.parseDailyForecast(for: context, data: json)
        return dailyForecast
    }
    
    func autocomplete(for text: String, context: NSManagedObjectContext) async -> [CityDataProviding]? {
        
        guard let encodedText = (text as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        
        let url = "\(String(.baseURL))/locations/v1/cities/autocomplete?apikey=\(self.keyAccuAPI)&q=\(encodedText)&\(self.languageURLKey)"
        
        let json = await self.getJSON(from: url)
        let parsedCityArray = self.parseCityAutocompleteArray(from: json, context: context)
        return parsedCityArray
    }
    
    func geopositionCity(for location: CLLocationCoordinate2D, context: NSManagedObjectContext) async -> CityDataProviding? {
        let url = "\(String(.baseURL))/locations/v1/cities/geoposition/search?apikey=\(self.keyAccuAPI)&q=\(location.latitude),\(location.longitude)&\(self.languageURLKey)"
        
        let json = await self.getJSON(from: url)
        let parsedCity = self.parseGeopositionCity(from: json, context: context)
        return parsedCity
    }
    
    private func fetchRequest(from urlString: String) async -> Data? {
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print("Error during fetchRequest: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getJSON(from urlString: String) async -> Any? {
        
        guard let data = await self.fetchRequest(from: urlString) else { return nil }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return json
        } catch {
            print("Error during getJSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: - Parsing functions
    
    private func parseHourlyForecast(for context: NSManagedObjectContext, data: Any?) -> [HourlyForecastProviding]? {
        
        guard let dataArray = data as? [[String : Any]] else { return nil }
        
        var hourlyForecastArray: [HourlyForecastProviding] = []
        
        for dataDictionary in dataArray {
            guard let hourlyForecastItem = HourlyForecast(for: context, data: dataDictionary) else { continue }
            hourlyForecastArray.append(hourlyForecastItem)
        }
        return hourlyForecastArray
    }
    
    private func parseDailyForecast(for context: NSManagedObjectContext, data: Any?) -> [DailyForecastProviding]? {
        
        guard let dataArray = (data as? [String : Any])?[String(.dailyForecast)] as? [[String : Any]] else { return nil }
        
        var dailyForecastArray: [DailyForecastProviding] = []
        
        for dataDictionary in dataArray {
            guard let dailyForecastItem = DailyForecast(for: context, data: dataDictionary) else { continue }
            dailyForecastArray.append(dailyForecastItem)
        }
        return dailyForecastArray
    }
    
    private func parseCityAutocompleteArray(from data: Any?, context: NSManagedObjectContext) -> [CityDataProviding]? {
        
        guard let dataArray = data as? [[String : Any]] else { return nil }
        
        var autocompletedCitiesArray = [CityDataProviding]()
        
        for dataDictionary in dataArray {
            if let key = dataDictionary[String(.cityID)] as? String,
               let name = dataDictionary[String(.cityName)] as? String {
                let city = City(context: context,
                                key: key,
                                name: name)
                autocompletedCitiesArray.append(city)
            }
        }
        
        return autocompletedCitiesArray
    }
    
    private func parseGeopositionCity(from data: Any?, context: NSManagedObjectContext) -> CityDataProviding? {
        
        guard let dataDictionary = data as? [String : Any] else { return nil }
        guard let key = dataDictionary[String(.cityID)] as? String else { return nil }
        guard let name = dataDictionary[String(.cityName)] as? String else { return nil }
        
        let city = City(context: context,
                        key: key,
                        name: name,
                        isLocated: true)        
        return city
    }
}
