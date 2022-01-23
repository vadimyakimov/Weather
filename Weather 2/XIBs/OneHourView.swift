//
//  OneHourView.swift
//  Weather 2
//
//  Created by Вадим on 21.01.2022.
//

import UIKit

class OneHourView: UIView {
    
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    let cornerRadius: CGFloat = 20

    static func instanceFromNib() -> OneHourView {
        return UINib(nibName: "OneHourView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! OneHourView
    }
    
    func configure(time: Date, temperature: Int, weatherText: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.timeLabel.text = formatter.string(from: time)
        self.temperatureLabel.text = "\(temperature)ºC"
        self.textLabel.text = weatherText
        self.layer.cornerRadius = self.cornerRadius
    }
    
    func setIcon(_ icon: UIImage) {
        self.iconImageView.image = icon
    }

}
