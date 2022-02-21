import Foundation

protocol CitiesListViewControllerDelegate: AnyObject {
    func citiesListViewController(didSelectRowAt indexPath: IndexPath)
    func citiesListViewController(shouldRemoveCityAt index: Int)
    func citiesListViewController(shouldMoveCityAt sourceIndex: Int, to destinationIndex: Int)
    func citiesListViewControllerWillDisappear()
    
    func searchScreenViewController(didSelectRowAt indexPath: IndexPath, autocompletedCity: City)
    func searchScreenViewController(didLoadLocaleCity city: City)
}
