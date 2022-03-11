import UIKit

class CityTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var locationIcon: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var viewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    static let cellHeight: CGFloat = 60
    
    // MARK: - Initializers
    
    static func instanceFronNib() -> CityTableViewCell {
        return UINib(nibName: "CityTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! CityTableViewCell
    }
    
    // MARK: - Configuration funcs
    
    func configure(width: CGFloat, text: String, isLocation: Bool = false) {
        self.viewHeightConstraint.constant = CityTableViewCell.cellHeight
        self.viewWidthConstraint.constant = width
        self.locationIcon.isHidden = !isLocation
        self.nameLabel.text = text
    }
    
    func startLoading() {
        self.locationIcon.isHidden = true
        self.loadingActivityIndicator.startAnimating()
    }
    
    func stopLoading() {
        self.locationIcon.isHidden = false
        self.loadingActivityIndicator.stopAnimating()
    }
    
}

