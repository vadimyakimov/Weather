import Foundation

@MainActor
protocol WeatherInfoViewDelegate: AnyObject {
    func weatherInfoViewDidFinishUpdating()
    func weatherInfoViewDidUpdateCurrentWeather()
}
