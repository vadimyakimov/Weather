import Foundation
import CoreData

protocol WeatherInfoProviding {
    var temperatureCelsius: Int16 { get }
    var temperatureFahrenheit: Int16 { get }
    var weatherIcon: Int16 { get }
    var weatherText: String { get }
}

protocol DailyForecastProviding {
    var forecastDate: Date { get }
    var dayWeather: WeatherInfo { get }
    var nightWeather: WeatherInfo { get }
}

protocol HourlyForecastProviding: WeatherInfoProviding {
    var forecastTime: Date { get }
}

protocol CurrentWeatherProviding: WeatherInfoProviding {
    var isDayTime: Bool { get }
}

protocol CityManagedEntity: NSManagedObject {
    var city: City? { get set }
}

protocol CityDataProviding: NSManagedObject {
    var id: Int16 { get set }
    var isLocated: Bool { get }
    var key: String { get }
    var name: String { get }
    var currentWeather: CurrentWeather? { get }
    var dailyForecast: NSOrderedSet? { get }
    var hourlyForecast: NSOrderedSet? { get }
    var lastUpdated: LastUpdated { get }
}
