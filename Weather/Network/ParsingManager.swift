import CoreData

class ParsingManager: DataParsing {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func parseCurrentWeather(from data: Any?) -> CurrentWeatherProviding? {
        return CurrentWeather(for: self.context, data: data)
    }
    
    
    func parseHourlyForecast(from data: Any?) -> [HourlyForecastProviding]? {
        
        guard let dataArray = data as? [[String : Any]] else { return nil }
        
        var hourlyForecastArray: [HourlyForecastProviding] = []
        
        for dataDictionary in dataArray {
            guard let hourlyForecastItem = HourlyForecast(for: self.context, data: dataDictionary) else { continue }
            hourlyForecastArray.append(hourlyForecastItem)
        }
        return hourlyForecastArray
    }
    
    func parseDailyForecast(from data: Any?) -> [DailyForecastProviding]? {
        
        guard let dataArray = (data as? [String : Any])?[String(.dailyForecast)] as? [[String : Any]] else { return nil }
        
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
