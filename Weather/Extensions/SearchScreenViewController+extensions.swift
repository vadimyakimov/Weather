import UIKit
import CoreLocation

// MARK: - Table View Data Source

extension SearchScreenViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            guard let count = self.citiesAutocompleteArray?.count else { return 0 }
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CityTableViewCell.instanceFronNib()
        let width = self.view.frame.width
        if indexPath.section == 0 {
            cell.configure(width: width, text: "My location".localized(), isLocation: true)
        } else {
            guard let citiesAutocompleteArray = self.citiesAutocompleteArray else { return UITableViewCell() }
            cell.configure(width: width, text: citiesAutocompleteArray[indexPath.row].name)
        }
        return cell
    }
}

//MARK: - Table View Updating

extension SearchScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.autocompleteSearchController.searchBar.resignFirstResponder()
        self.autocompleteSearchController.hidesNavigationBarDuringPresentation = false
        
        if indexPath.section == 0 {
            self.startLoadingAnimation()
            self.requestLocation()
        } else {
            guard let citiesAutocompleteArray = self.citiesAutocompleteArray else { return }
            let city = citiesAutocompleteArray[indexPath.row]
            self.delegate?.searchScreenViewController(didSelectRowAt: indexPath, autocompletedCity: city)
        }
    }
}

//MARK: - Search Results Updating

extension SearchScreenViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        
        self.autocompleteTimer.invalidate()
        self.autocompleteTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { _ in
            self.networkManager.autocomplete(for: searchText) {cityArray in
                self.citiesAutocompleteArray = cityArray
                DispatchQueue.main.async {
                    self.autocompleteTimer.invalidate()
                    self.searchTableView.reloadData()
                }
            }
        })
    }
}

//MARK: - Search Controller Delegate

extension SearchScreenViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}


//MARK: - Location Manager Updating

extension SearchScreenViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else {
            showLocationErrorAlert()
            return
        }
        self.networkManager.geopositionCity(for: location.coordinate) {city in
            self.delegate?.searchScreenViewController(didLoadLocaleCity: city)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        self.stopLoadingAnimation()
        
        if #available(iOS 14.0, *), locationManager.authorizationStatus == .notDetermined {
                return
        } else {
            showLocationErrorAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.startLoadingAnimation()
            manager.requestLocation()
        }        
    }
    
}

