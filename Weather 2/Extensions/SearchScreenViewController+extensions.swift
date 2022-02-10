//
//  SearchScreenViewController+extensions.swift
//  Weather 2
//
//  Created by Вадим on 13.01.2022.
//

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
            return Manager.shared.citiesAutocompleteArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.searchCellId) as? CityTableViewCell else { return UITableViewCell() }
        let cell = CityTableViewCell.instanceFronNib()
        let width = self.view.frame.width
        if indexPath.section == 0 {
            cell.configure(width: width, text: "My location".localized(), isLocation: true)
        } else {
            cell.configure(width: width, text: Manager.shared.citiesAutocompleteArray[indexPath.row].name)
        }
        return cell
    }
}

extension SearchScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selectRow")
        if indexPath.section == 0 {
            self.requestLocation()
            //====================================================
        } else {
            self.delegate?.searchScreenViewController(didSelectRowAt: indexPath) 
        }
    }
    
}

// MARK: - Search Bar Delegate

extension SearchScreenViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.autocompleteTimer?.invalidate()
        self.autocompleteTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { _ in
            self.autocomplete(for: searchText) {
                DispatchQueue.main.async {
                    self.autocompleteTimer?.invalidate()
                    self.searchTableView.reloadData()
                }
            }            
        })      
    }

}

extension SearchScreenViewController: CLLocationManagerDelegate {
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else { return }
        self.geopositionCity(for: location.coordinate) {city in 
            self.locationManager.stopUpdatingLocation()
            self.delegate?.searchScreenViewController(didLoadLocaleCity: city)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print(status.rawValue)
        
        
        if status == .denied {
            
        } else {
        }
        
    }
    
}

