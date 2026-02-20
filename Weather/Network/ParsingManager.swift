import CoreData

class ParsingManager: DataParsing {
    
    private let context: NSManagedObjectContext
    private enum ParsingError: Error {
        case currentWeather
        case hourlyForecast
        case dailyForecast
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func parseCurrentWeather(from data: Any?) throws -> CurrentWeatherProviding {
        let currentWeather = CurrentWeather(for: self.context, data: data)
        guard let currentWeather else {
            throw ParsingError.currentWeather
        }
        return currentWeather
    }
    
    
    func parseHourlyForecast(from data: Any?) throws -> [HourlyForecastProviding] {
        
        guard let dataArray = data as? [[String : Any]] else {
            throw ParsingError.hourlyForecast
        }
        
        var hourlyForecastArray: [HourlyForecastProviding] = []
        
        for dataDictionary in dataArray {
            guard let hourlyForecastItem = HourlyForecast(for: self.context, data: dataDictionary) else { continue }
            hourlyForecastArray.append(hourlyForecastItem)
        }
        return hourlyForecastArray
    }
    
    func parseDailyForecast(from data: Any?) throws -> [DailyForecastProviding] {
                
        guard let dataArray = (data as? [String : Any])?[String(.dailyForecast)] as? [[String : Any]] else {
            throw ParsingError.dailyForecast
        }
        
        var dailyForecastArray: [DailyForecastProviding] = []
        
        for dataDictionary in dataArray {
            guard let dailyForecastItem = DailyForecast(for: self.context, data: dataDictionary) else { continue }
            dailyForecastArray.append(dailyForecastItem)
        }
        return dailyForecastArray
    }
    
    func parseCityAutocompleteArray(from data: Any?) -> [CityDataProviding]? {
        
        guard let dataArray = data as? [[String : Any]] else { return nil }
        
        var autocompletedCitiesArray = [CityDataProviding]()
        
        for dataDictionary in dataArray {
            if let key = dataDictionary[String(.cityID)] as? String,
               let name = dataDictionary[String(.cityName)] as? String {
                let city = City(context: self.context,
                                key: key,
                                name: name)
                autocompletedCitiesArray.append(city)
            }
        }
        
        return autocompletedCitiesArray
    }
    
    func parseGeopositionCity(from data: Any?) -> CityDataProviding? {
        
        guard let dataDictionary = data as? [String : Any] else { return nil }
        guard let key = dataDictionary[String(.cityID)] as? String else { return nil }
        guard let name = dataDictionary[String(.cityName)] as? String else { return nil }
        
        let city = City(context: self.context,
                        key: key,
                        name: name,
                        isLocated: true)
        return city
    }
}
