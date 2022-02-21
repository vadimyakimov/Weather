import Foundation
import UIKit

protocol CityViewControllerDelegate: AnyObject {
    func cityViewController(didUpdateCurrentWeatherFor city: City)
    func cityViewController(didUpdateHourlyForecastFor city: City)
    func cityViewController(didUpdateDailyForecastFor city: City)
    func cityViewController(scrollViewDidScroll scrollView: UIScrollView)    
}
