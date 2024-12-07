import Foundation
import UIKit

protocol CityViewControllerDelegate: AnyObject {    
    func cityViewController(scrollViewDidScroll scrollView: UIScrollView)
}
