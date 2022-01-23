//
//  CurrentWeatherView.swift
//  Weather 2
//
//  Created by Вадим on 21.01.2022.
//

import Foundation
import UIKit

class CurrentWeatherView: UIView {
    
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    private let cornerRadius: CGFloat = 30
    
    
    static func instanceFromNib() -> CurrentWeatherView {
        return UINib(nibName: "CurrentWeatherView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! CurrentWeatherView
    }
    
    func configure(isDayTime: Bool, temperature: Int, weatherText: String) {
        let dayColor = UIColor(red: 0.52, green: 0, blue: 0.16, alpha: 1)
        let nightColor = UIColor(red: 0.26, green: 0.47, blue: 1, alpha: 1)
        self.backgroundColor = isDayTime ? dayColor : nightColor
        self.temperatureLabel.text = "\(temperature)ºC"
        self.textLabel.text = "\(weatherText)"
        self.layer.cornerRadius = self.cornerRadius        
    }
    
    func setIcon(_ icon: UIImage) {
        self.iconImageView.image = icon
    }
    
}
