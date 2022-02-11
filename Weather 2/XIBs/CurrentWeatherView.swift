//
//  CurrentWeatherView.swift
//  Weather 2
//
//  Created by Вадим on 21.01.2022.
//

import Foundation
import UIKit
import SkeletonView

class CurrentWeatherView: UIView {
    
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    private let cornerRadius: CGFloat = 30
    private let dayColor = UIColor(red: 0.52, green: 0, blue: 0.16, alpha: 1)
    private let nightColor = UIColor(red: 0.26, green: 0.47, blue: 1, alpha: 1)
    
    static func instanceFromNib() -> CurrentWeatherView {
        return UINib(nibName: "CurrentWeatherView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! CurrentWeatherView
    }
    
    func configure(isDayTime: Bool?) {
        self.layer.cornerRadius = self.cornerRadius
        self.startSkeleton(isDayTime: isDayTime)
    }
    
    func configure(isDayTime: Bool, temperature: Int, weatherText: String) {
        self.backgroundColor = self.color(isDayTime: isDayTime)
        self.temperatureLabel.text = "\(temperature)ºC"
        self.textLabel.text = "\(weatherText)"
        self.layer.cornerRadius = self.cornerRadius
        self.stopSkeleton()
    }
    
    func setIcon(_ icon: UIImage) {
        self.iconImageView.image = icon
        self.iconImageView.hideSkeleton()
    }
    
    func startSkeleton(isDayTime: Bool?) {
        
        self.isSkeletonable = true
        self.skeletonCornerRadius = Float(self.cornerRadius)
        self.showAnimatedSkeleton(usingColor: self.color(isDayTime: isDayTime))
        
        self.iconImageView.isSkeletonable = true
        self.iconImageView.isHiddenWhenSkeletonIsActive = true
        self.iconImageView.showSkeleton()
    }
    
    private func stopSkeleton() {
        self.hideSkeleton()
    }
    
    private func color(isDayTime: Bool?) -> UIColor {
        if isDayTime == false {
            return self.nightColor
        } else {
            return self.dayColor
        }
    }
    
}
