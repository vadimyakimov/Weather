import Foundation

protocol WeatherInfoViewDelegate: AnyObject {
    func weatherInfoView(didUpdateWeatherInfoFor city: City)
    func weatherInfoView(didUpdateCurrentWeatherFor city: City)
    func weatherInfoView(didUpdateHourlyForecastFor city: City)
    func weatherInfoView(didUpdateDailyForecastFor city: City)
}
