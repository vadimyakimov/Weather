import CoreLocation

class NetworkManager: WeatherProviding, CityProviding {
        
    // MARK: Properties

    let dataParser: DataParsing
    let dataLoader: JSONDataProviding
    let keyAccuAPI: String
    let languageURLKey = "language=" + "en-us".localized()
    
    
    // MARK: - Initializers
    
    init(dataParser: DataParsing, dataLoader: JSONDataProviding, APIKey: String) {
        self.dataParser = dataParser
        self.dataLoader = dataLoader
        self.keyAccuAPI = APIKey
    }
    
    // MARK: - Server connection functions
    
    func getCurrentWeather(by cityKey: String) async -> CurrentWeatherProviding? {
        
        let url = "\(String(.baseURL))/currentconditions/v1/\(cityKey)?apikey=\(self.keyAccuAPI)&\(self.languageURLKey)"
        
        let json = await self.dataLoader.getJSON(from: url)
        let currentWeather = self.dataParser.parseCurrentWeather(from: json)
        
        return currentWeather
    }
    
    func getHourlyForecast(by cityKey: String) async -> [HourlyForecastProviding]? {
        
        let url = "\(String(.baseURL))/forecasts/v1/hourly/12hour/\(cityKey)?apikey=\(self.keyAccuAPI)&\(self.languageURLKey)&metric=true"
        
        let json = await self.dataLoader.getJSON(from: url)
        let hourlyForecast = self.dataParser.parseHourlyForecast(from: json)
        return hourlyForecast
    }
    
    func getDailyForecast(by cityKey: String) async -> [DailyForecastProviding]? {
        
        let url = "\(String(.baseURL))/forecasts/v1/daily/5day/\(cityKey)?apikey=\(self.keyAccuAPI)&\(self.languageURLKey)&metric=true"
        
        let json = await self.dataLoader.getJSON(from: url)
        let dailyForecast = self.dataParser.parseDailyForecast(from: json)
        return dailyForecast
    }
    
    func autocomplete(for text: String) async -> [CityDataProviding]? {
        
        guard let encodedText = (text as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        
        let url = "\(String(.baseURL))/locations/v1/cities/autocomplete?apikey=\(self.keyAccuAPI)&q=\(encodedText)&\(self.languageURLKey)"
        
        let json = await self.dataLoader.getJSON(from: url)
        let parsedCityArray = self.dataParser.parseCityAutocompleteArray(from: json)
        return parsedCityArray
    }
    
    func geopositionCity(for location: CLLocationCoordinate2D) async -> CityDataProviding? {
        let url = "\(String(.baseURL))/locations/v1/cities/geoposition/search?apikey=\(self.keyAccuAPI)&q=\(location.latitude),\(location.longitude)&\(self.languageURLKey)"
        
        let json = await self.dataLoader.getJSON(from: url)
        let parsedCity = self.dataParser.parseGeopositionCity(from: json)
        return parsedCity
    }
}
