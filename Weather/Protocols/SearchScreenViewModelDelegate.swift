import Foundation

protocol SearchScreenViewControllerDelegate: AnyObject {
    func searchScreenViewController(didDirectToCityWithIndex index: Int)
}
