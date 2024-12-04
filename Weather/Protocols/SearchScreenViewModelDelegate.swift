import Foundation

protocol SearchScreenViewControllerDelegate: AnyObject {
    func searchScreenViewController(isRoot: Bool, didSelectAutocompletedCity city: City)
    func searchScreenViewController(isRoot: Bool, didLoadLocalCity city: City)
}
