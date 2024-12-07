import UIKit
import SkeletonView

class OneHourView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    // MARK: - Properties
    
    private let cornerRadius: CGFloat = 20
    private let skeletonCustomCornerRadius = 8
    
    // MARK: - Initializers
    
    static func instanceFromNib() -> OneHourView {
        return UINib(nibName: "OneHourView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! OneHourView
    }
    
    // MARK: - Configuration funcs
    
    func configure() {
        self.layer.cornerRadius = self.cornerRadius
        self.startSkeleton()
    }
    
    func configure(time: Date, temperature: Int, weatherText: String, weatherIcon: Int) {        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.timeLabel.text = formatter.string(from: time)
        self.temperatureLabel.text = "\(temperature)ºC"
        self.textLabel.text = weatherText
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
    
    func startSkeleton() {        
        self.createSkeletonFor(label: self.timeLabel)
        self.createSkeletonFor(label: self.temperatureLabel)
        self.createSkeletonFor(imageView: self.iconImageView)
        self.textLabel.skeletonTextNumberOfLines = 1
        self.createSkeletonFor(label: self.textLabel)
    }
    
    private func stopSkeleton() {
        self.timeLabel.hideSkeleton()
        self.temperatureLabel.hideSkeleton()
        self.textLabel.hideSkeleton()
    }
    
    private func createSkeletonFor(label: UILabel) {
        let baseColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.2)
        let secondaryColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.3)
        let gradient = SkeletonGradient(baseColor: baseColor, secondaryColor: secondaryColor)
        
        label.isSkeletonable = true
        label.skeletonTextLineHeight = .relativeToConstraints
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
