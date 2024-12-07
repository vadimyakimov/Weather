import Foundation
import UIKit
import SkeletonView

class CurrentWeatherView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    // MARK: - Properties
    
    private let cornerRadius: CGFloat = 30
    private let dayColor = UIColor(red: 0.52, green: 0, blue: 0.16, alpha: 1)
    private let nightColor = UIColor(red: 0.26, green: 0.47, blue: 1, alpha: 1)
    
    // MARK: - Initializers
    
    static func instanceFromNib() -> CurrentWeatherView {
        return UINib(nibName: "CurrentWeatherView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! CurrentWeatherView
    }
    
    // MARK: - Configuration funcs
    
    func configure(isDayTime: Bool?) {
        self.layer.cornerRadius = self.cornerRadius
        self.startSkeleton(isDayTime: isDayTime)
    }
    
    func configure(isDayTime: Bool, temperature: Int, weatherText: String, weatherIcon: Int) {
        self.backgroundColor = self.color(isDayTime: isDayTime)
        self.temperatureLabel.text = "\(temperature)ºC"
        self.textLabel.text = "\(weatherText)"
        self.layer.cornerRadius = self.cornerRadius
        
        self.stopSkeleton()
        
        NetworkManager.shared.getImage(iconNumber: weatherIcon) { icon in
            self.setIcon(icon)
        }
    }
    
    private func setIcon(_ icon: UIImage) {
        self.iconImageView.image = icon
        self.iconImageView.hideSkeleton()
    }
    
    // MARK: - Skeleton funcs
    
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
