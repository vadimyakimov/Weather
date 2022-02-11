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
        createSkeletonFor(label: self.dayLabel)
        createSkeletonFor(label: self.dateLabel)
        createSkeletonFor(label: self.dayTemperatureLabel)
        createSkeletonFor(label: self.nightTemperatureLabel)
        createSkeletonFor(imageView: self.dayIconImageView)
        createSkeletonFor(imageView: self.nightIconImageView)
    }
    
    private func stopSkeleton() {
        self.dayLabel.hideSkeleton()
        self.dateLabel.hideSkeleton()
        self.dayTemperatureLabel.hideSkeleton()
        self.nightTemperatureLabel.hideSkeleton()
    }
    
    private func createSkeletonFor(label: UILabel) {
        label.isSkeletonable = true
        label.skeletonTextLineHeight = .relativeToFont
        label.lastLineFillPercent = 100
        label.linesCornerRadius = self.skeletonCustomCornerRadius
        label.showAnimatedGradientSkeleton()
    }
    
    private func createSkeletonFor(imageView: UIImageView) {
        imageView.isSkeletonable = true
        imageView.isHiddenWhenSkeletonIsActive = true
        imageView.showAnimatedGradientSkeleton()
    }
}
