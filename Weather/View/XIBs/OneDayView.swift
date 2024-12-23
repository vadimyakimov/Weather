import UIKit
import SkeletonView

class OneDayView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var dayIconImageView: UIImageView!
    @IBOutlet private weak var dayTemperatureLabel: UILabel!
    @IBOutlet private weak var nightIconImageView: UIImageView!
    @IBOutlet private weak var nightTemperatureLabel: UILabel!
    
    // MARK: - Properties
    
    var dayTemperature: Temperature?
    var nightTemperature: Temperature?
    
    private let skeletonCustomCornerRadius = 8
    
    // MARK: - Initializers
    
    static func instanceFronNib() -> OneDayView {
        return UINib(nibName: "OneDayView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! OneDayView
    }
    
    // MARK: - Configuration funcs
    
    func configure() {
        self.startSkeleton()
    }
    
    func configure(date: Date, dayTemperature: Temperature, nightTemperature: Temperature, dayIcon: Int, nightIcon: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        self.dayLabel.text = formatter.string(from: date)
        formatter.dateFormat = "dd"
        self.dateLabel.text = formatter.string(from: date)
                
        self.dayTemperature = dayTemperature
        dayTemperature.bind { value in
            self.dayTemperatureLabel.text = value
        }
        
        self.nightTemperature = nightTemperature
        nightTemperature.bind { value in
            self.nightTemperatureLabel.text = value
        }
        
        self.stopSkeleton()
        
        NetworkManager.shared.getImage(iconNumber: dayIcon) { icon in
            self.setDayIcon(icon)
        }
        NetworkManager.shared.getImage(iconNumber: nightIcon) { icon in
            self.setNightIcon(icon)
        }
    }
    
    private func setDayIcon(_ icon: UIImage) {
        self.dayIconImageView.image = icon
        self.dayIconImageView.hideSkeleton()
    }
    
    private func setNightIcon(_ icon: UIImage) {
        self.nightIconImageView.image = icon
        self.nightIconImageView.hideSkeleton()
    }
    
    // MARK: - Skeleton funcs
    
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
