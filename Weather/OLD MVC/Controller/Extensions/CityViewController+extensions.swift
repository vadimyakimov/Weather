//import Foundation
//import UIKit
//
//
//// MARK: - Scroll View Delegate
//
//extension CityViewController: UIScrollViewDelegate {       
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        UIView.animate(withDuration: 1) {
//            self.addFade(to: scrollView)
//        }
//        self.delegate?.cityViewController(scrollViewDidScroll: scrollView)
//    }
//    
//}
//
//// MARK: - Weather Info View Delegate
//
//extension CityViewController: WeatherInfoViewDelegate {
//    
//    func weatherInfoView(didUpdateWeatherInfoFor city: City) {
//        self.cityRefreshControl.endRefreshing()
//    }
//    
//    func weatherInfoView(didUpdateCurrentWeatherFor city: City) {
//        self.delegate?.cityViewController(didUpdateCurrentWeatherFor: self.city)
//    }
//    
//    func weatherInfoView(didUpdateHourlyForecastFor city: City) {
//        self.delegate?.cityViewController(didUpdateHourlyForecastFor: self.city)
//    }
//    
//    func weatherInfoView(didUpdateDailyForecastFor city: City) {
//        self.delegate?.cityViewController(didUpdateDailyForecastFor: self.city)
//    }
//    
//}
