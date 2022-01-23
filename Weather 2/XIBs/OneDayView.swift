//
//  DailyForecastView.swift
//  Weather 2
//
//  Created by Вадим on 22.01.2022.
//

import UIKit

class OneDayView: UIView {
    
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var dayIconImageView: UIImageView!
    @IBOutlet private weak var dayTemperatureLabel: UILabel!
    @IBOutlet private weak var nightIconImageView: UIImageView!
    @IBOutlet private weak var nightTemperatureLabel: UILabel!
    

    static func instanceFronNib() -> OneDayView {
        return UINib(nibName: "OneDayView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! OneDayView
    }
    
    func configure(date: Date, dayTemperature: Int, nightTemperature: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        self.dayLabel.text = formatter.string(from: date)
        formatter.dateFormat = "dd"
        self.dateLabel.text = formatter.string(from: date)
        
        self.dayTemperatureLabel.text  = "\(dayTemperature)ºC"
        self.nightTemperatureLabel.text  = "\(nightTemperature)ºC"
    }
    
    func setDayIcon(_ icon: UIImage) {
        self.dayIconImageView.image = icon
    }
    
    func setNightIcon(_ icon: UIImage) {
        self.nightIconImageView.image = icon
    }
}
