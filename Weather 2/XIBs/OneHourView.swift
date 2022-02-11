//
//  OneHourView.swift
//  Weather 2
//
//  Created by Вадим on 21.01.2022.
//

import UIKit
import SkeletonView

class OneHourView: UIView {
    
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    private let cornerRadius: CGFloat = 20
    private let skeletonCustomCornerRadius = 8
    
    static func instanceFromNib() -> OneHourView {
        return UINib(nibName: "OneHourView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! OneHourView
    }
    
    func configure() {
        self.layer.cornerRadius = self.cornerRadius
        self.startSkeleton()
    }
    
    func configure(time: Date, temperature: Int, weatherText: String) {        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.timeLabel.text = formatter.string(from: time)
        self.temperatureLabel.text = "\(temperature)ºC"
        self.textLabel.text = weatherText
        self.layer.cornerRadius = self.cornerRadius
        
        self.stopSkeleton()
    }
    
    func setIcon(_ icon: UIImage) {
        self.iconImageView.image = icon
        self.iconImageView.hideSkeleton()
    }
    
    func startSkeleton() {
        createSkeletonFor(label: self.timeLabel)
        createSkeletonFor(label: self.temperatureLabel)
        createSkeletonFor(label: self.textLabel)
        createSkeletonFor(imageView: self.iconImageView)
    }
    
    private func stopSkeleton() {
        self.timeLabel.hideSkeleton()
        self.temperatureLabel.hideSkeleton()
        self.textLabel.hideSkeleton()
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
