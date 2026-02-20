import Foundation

@MainActor
protocol WeatherInfoViewDelegate: AnyObject {
    func weatherInfoViewDidFinishUpdating(_ isSuccess: Bool)
    func weatherInfoViewDidUpdateCurrentWeather()
    
}
