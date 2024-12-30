import Foundation

@MainActor
protocol SearchScreenViewControllerDelegate: AnyObject {
    func searchScreenViewController(didDirectToCityWithIndex index: Int)
}
