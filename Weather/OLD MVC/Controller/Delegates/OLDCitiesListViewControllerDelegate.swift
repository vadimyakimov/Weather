import Foundation

protocol OLDCitiesListViewControllerDelegate: AnyObject {
    func citiesListViewController(didSelectRowAt indexPath: IndexPath)
    func citiesListViewController(shouldRemoveCityAt index: Int)
    func citiesListViewController(shouldMoveCityAt sourceIndex: Int, to destinationIndex: Int)
    func citiesListViewControllerWillDisappear()
}
