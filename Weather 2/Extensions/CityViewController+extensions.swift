//
//  CityViewController+extensions.swift
//  Weather 2
//
//  Created by Вадим on 21.01.2022.
//

import Foundation
import UIKit


// MARK: - Scroll View Delegate

extension CityViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 1) {
            self.addFade(to: scrollView)
        }
        let fontSize = self.nameLabelFontSize - scrollView.contentOffset.y
        if fontSize < self.nameLabelFontSize * 2 &&
           fontSize > self.nameLabelMinimumFontSize {
            self.nameLabel.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

// MARK: - Weather Info View Delegate

extension CityViewController: WeatherInfoViewDelegate {
    
    func weatherInfoView(didUpdateCurrentWeatherFor city: City) {
        self.delegate?.cityViewController(didUpdateCurrentWeatherFor: self.city)
    }
    
}
