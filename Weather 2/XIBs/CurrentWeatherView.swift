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
    
    func configure() {
        self.layer.cornerRadius = self.cornerRadius
        self.startSkeleton(color: self.dayColor)
    }
    
    func configure(isDayTime: Bool, temperature: Int, weatherText: String) {        
        let backgroundColor = isDayTime ? self.dayColor : self.nightColor
        self.backgroundColor = backgroundColor
        self.temperatureLabel.text = "\(temperature)ºC"
        self.textLabel.text = "\(weatherText)"
        self.layer.cornerRadius = self.cornerRadius
        self.stopSkeleton()
    }
    
    func setIcon(_ icon: UIImage) {
        self.iconImageView.image = icon
        self.iconImageView.hideSkeleton()
    }
    
    private func startSkeleton(color: UIColor) {
        self.isSkeletonable = true
        self.skeletonCornerRadius = Float(self.cornerRadius)
        self.showAnimatedSkeleton(usingColor: color)
        
        self.iconImageView.isSkeletonable = true
        self.iconImageView.isHiddenWhenSkeletonIsActive = true
        self.iconImageView.showSkeleton()
    }
    
    private func stopSkeleton() {
        self.hideSkeleton()
    }
    
}
