import Foundation
import UIKit
import SkeletonView

class CurrentWeatherView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    // MARK: - Properties
    
    var temperature: Temperature?
    
    private let cornerRadius: CGFloat = 30
    private let dayColor = UIColor(red: 0.52, green: 0, blue: 0.16, alpha: 1)
    private let nightColor = UIColor(red: 0.26, green: 0.47, blue: 1, alpha: 1)
    
    // MARK: - Initializers
    
    static func instanceFromNib() -> CurrentWeatherView {
        return UINib(nibName: String(CurrentWeatherView.self), bundle: nil).instantiate(withOwner: nil, options: nil).first as! CurrentWeatherView
    }
    
    // MARK: - Configuration funcs
    
    func configure(isDayTime: Bool?) {
        self.layer.cornerRadius = self.cornerRadius
        
        self.isSkeletonable = true
        self.skeletonCornerRadius = Float(self.cornerRadius)
        self.iconImageView.isSkeletonable = true
        self.iconImageView.isHiddenWhenSkeletonIsActive = true
        
        self.startSkeleton(isDayTime: isDayTime)
    }
    
    func configure(isDayTime: Bool, temperature: Temperature, weatherText: String, weatherIcon: Int) {
        
        self.stopSkeleton()
        
        self.temperature = temperature
        temperature.bind { [unowned self] value in
            self.temperatureLabel.text = value
        }
        
        self.backgroundColor = self.color(isDayTime: isDayTime)
        self.textLabel.text = weatherText
        self.layer.cornerRadius = self.cornerRadius
        
        Task { [unowned self] in
            let image = await ImageLoader.shared.getImage(weatherIcon)
            self.setIcon(image)
        }
    }
    
    private func setIcon(_ icon: UIImage?) {
        self.iconImageView.image = icon
        self.iconImageView.hideSkeleton()
    }
    
    // MARK: - Skeleton funcs
    
    func startSkeleton(isDayTime: Bool?) {
        self.showAnimatedSkeleton(usingColor: self.color(isDayTime: isDayTime))
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
