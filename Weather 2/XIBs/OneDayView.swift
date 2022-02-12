//
//  DailyForecastView.swift
//  Weather 2
//
//  Created by Вадим on 22.01.2022.
//

import UIKit
import SkeletonView

class OneDayView: UIView {
    
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var dayIconImageView: UIImageView!
    @IBOutlet private weak var dayTemperatureLabel: UILabel!
    @IBOutlet private weak var nightIconImageView: UIImageView!
    @IBOutlet private weak var nightTemperatureLabel: UILabel!
    
    private let skeletonCustomCornerRadius = 8

    static func instanceFronNib() -> OneDayView {
        return UINib(nibName: "OneDayView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! OneDayView
    }
    
    func configure() {
        self.startSkeleton()
    }
    
    func configure(date: Date, dayTemperature: Int, nightTemperature: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        self.dayLabel.text = formatter.string(from: date)
        formatter.dateFormat = "dd"
        self.dateLabel.text = formatter.string(from: date)
        
        self.dayTemperatureLabel.text  = "\(dayTemperature)ºC"
        self.nightTemperatureLabel.text  = "\(nightTemperature)ºC"
        
        self.stopSkeleton()
    }
    
    func setDayIcon(_ icon: UIImage) {
        self.dayIconImageView.image = icon
        self.dayIconImageView.hideSkeleton()
    }
    
    func setNightIcon(_ icon: UIImage) {
        self.nightIconImageView.image = icon
        self.nightIconImageView.hideSkeleton()
    }
        
    func startSkeleton() {
        self.createSkeletonFor(label: self.dayLabel)
        self.createSkeletonFor(label: self.dateLabel)
        self.createSkeletonFor(label: self.dayTemperatureLabel)
        self.createSkeletonFor(label: self.nightTemperatureLabel)
        self.createSkeletonFor(imageView: self.dayIconImageView)
        self.createSkeletonFor(imageView: self.nightIconImageView)
    }
    
    private func stopSkeleton() {
        self.dayLabel.hideSkeleton()
        self.dateLabel.hideSkeleton()
        self.dayTemperatureLabel.hideSkeleton()
        self.nightTemperatureLabel.hideSkeleton()
    }
    
    private func createSkeletonFor(label: UILabel) {
        let baseColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.2)
        let secondaryColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.3)
        let gradient = SkeletonGradient(baseColor: baseColor, secondaryColor: secondaryColor)
        
        label.isSkeletonable = true
        label.skeletonTextLineHeight = .relativeToFont
        label.lastLineFillPercent = 100
        label.linesCornerRadius = self.skeletonCustomCornerRadius
        label.showAnimatedGradientSkeleton(usingGradient: gradient)
    }
    
    private func createSkeletonFor(imageView: UIImageView) {
        imageView.isSkeletonable = true
        imageView.isHiddenWhenSkeletonIsActive = true
        imageView.showAnimatedGradientSkeleton()
    }
}
