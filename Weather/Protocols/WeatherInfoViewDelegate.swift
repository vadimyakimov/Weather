import Foundation

protocol WeatherInfoViewDelegate: AnyObject {
    func weatherInfoViewDidFinishUpdating()
    func weatherInfoViewDidUpdateCurrentWeather()
}
