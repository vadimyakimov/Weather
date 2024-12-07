import Foundation

@objc protocol WeatherInfoViewDelegate: AnyObject {
    @objc optional func weatherInfoView(didUpdateWeatherInfoFor city: City)
    @objc optional func weatherInfoView(didUpdateCurrentWeatherFor city: City)
}
