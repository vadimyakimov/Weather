import Foundation

protocol SearchScreenViewControllerDelegate: AnyObject {
    func searchScreenViewController(didSelectRowAt indexPath: IndexPath, autocompletedCity: City)
    func searchScreenViewController(didLoadLocaleCity city: City)
}
