import Foundation
import UIKit

@MainActor
protocol CityViewControllerDelegate: AnyObject {
    func cityViewController(scrollViewDidScroll scrollView: UIScrollView)
}
