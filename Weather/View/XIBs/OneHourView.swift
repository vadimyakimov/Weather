import UIKit
import SkeletonView

class OneHourView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    // MARK: - Properties
    
    var temperature: Temperature?
    
    private let cornerRadius: CGFloat = 20
    private let skeletonCustomCornerRadius = 8
    
    // MARK: - Initializers
    
    static func instanceFromNib() -> OneHourView {
        return UINib(nibName: String(OneHourView.self), bundle: nil).instantiate(withOwner: nil, options: nil).first as! OneHourView
    }
    
    // MARK: - Configuration funcs
    
    func configure() {
        
        self.layer.cornerRadius = self.cornerRadius
        
        self.isSkeletonable = true
        self.createSkeletonFor(imageView: self.iconImageView)
        self.createSkeletonFor(label: self.timeLabel)
        self.createSkeletonFor(label: self.temperatureLabel)
        self.createSkeletonFor(label: self.textLabel)
        self.textLabel.skeletonTextNumberOfLines = 1
        
        self.startSkeleton()
    }
    
    func configure(time: Date, temperature: Temperature, weatherText: String, weatherIcon: Int) {
        
        self.stopSkeleton()
        
        self.temperature = temperature
        temperature.bind { [unowned self] value in
            self.temperatureLabel.text = value
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.timeLabel.text = formatter.string(from: time)
        self.textLabel.text = weatherText
        self.layer.cornerRadius = self.cornerRadius
        
        Task { [unowned self] in            
            let image = await NetworkManager.shared.getImage(weatherIcon)
            self.setIcon(image)
        }
    }
    
    private func setIcon(_ icon: UIImage?) {
        self.iconImageView.image = icon
        self.iconImageView.hideSkeleton()
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
        label.skeletonTextLineHeight = .relativeToConstraints
        label.lastLineFillPercent = 100
        label.linesCornerRadius = self.skeletonCustomCornerRadius
    }
    
    private func createSkeletonFor(imageView: UIImageView) {
        imageView.isSkeletonable = true
        imageView.isHiddenWhenSkeletonIsActive = true
    }
    
}
