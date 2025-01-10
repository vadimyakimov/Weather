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
        return UINib(nibName: String(OneDayView.self), bundle: nil).instantiate(withOwner: self).first as! OneDayView
    }
    
    // MARK: - Configuration funcs
    
    func configure() {
        
        self.isSkeletonable = true
        self.createSkeletonFor(label: self.dayLabel)
        self.createSkeletonFor(label: self.dateLabel)
        self.createSkeletonFor(label: self.dayTemperatureLabel)
        self.createSkeletonFor(label: self.nightTemperatureLabel)
        self.createSkeletonFor(imageView: self.dayIconImageView)
        self.createSkeletonFor(imageView: self.nightIconImageView)
        
        self.startSkeleton()
    }
    
    func configure(date: Date, dayTemperature: Temperature, nightTemperature: Temperature, dayIcon: Int, nightIcon: Int) {
        
        self.stopSkeleton()
        
        self.dayTemperature = dayTemperature
        dayTemperature.bind { [unowned self] value in
            self.dayTemperatureLabel.text = value
        }
        
        self.nightTemperature = nightTemperature
        nightTemperature.bind { [unowned self] value in
            self.nightTemperatureLabel.text = value
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        self.dayLabel.text = formatter.string(from: date)
        formatter.dateFormat = "dd"
        self.dateLabel.text = formatter.string(from: date)
        
        Task { [unowned self] in
                        
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    let dayImage = await ImageLoader.shared.getImage(dayIcon)
                    await self.setDayIcon(dayImage)
                }
                group.addTask {
                    let nightImage = await ImageLoader.shared.getImage(nightIcon)
                    await self.setNightIcon(nightImage)
                }
            }
        }
    }
    
    private func setDayIcon(_ icon: UIImage?) {
        self.dayIconImageView.image = icon
        self.dayIconImageView.hideSkeleton()
    }
    
    private func setNightIcon(_ icon: UIImage?) {
        self.nightIconImageView.image = icon
        self.nightIconImageView.hideSkeleton()
    }
    
    // MARK: - Skeleton funcs
    
    func startSkeleton() {
        let baseColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.2)
        let secondaryColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.3)
        let gradient = SkeletonGradient(baseColor: baseColor, secondaryColor: secondaryColor)
        
        self.showAnimatedGradientSkeleton(usingGradient: gradient)
    }
    
    private func stopSkeleton() {
        self.hideSkeleton()
    }
    
    private func createSkeletonFor(label: UILabel) {
        label.isSkeletonable = true
        label.skeletonTextLineHeight = .relativeToFont
        label.lastLineFillPercent = 100
        label.linesCornerRadius = self.skeletonCustomCornerRadius
    }
    
    private func createSkeletonFor(imageView: UIImageView) {
        imageView.isSkeletonable = true
        imageView.isHiddenWhenSkeletonIsActive = true
    }
}
