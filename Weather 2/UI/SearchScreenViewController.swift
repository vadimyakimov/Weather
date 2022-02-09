//
//  SearchViewController.swift
//  Weather 2
//
//  Created by Вадим on 12.01.2022.
//

import UIKit
import CoreLocation


class SearchScreenViewController: UIViewController {
    
    
    // MARK: - Properties
    
    weak var delegate: SearchScreenViewControllerDelegate?
    
    var searchTableView = UITableView()
    
    var autocompleteTimer: Timer?
    
    var autocompleteSearchBar = UISearchBar()
    
    private let autocompleteSearchBarHeight: CGFloat = 60
    let searchCellId = "autocompleteCell"
    
    // API keys
    
    private let baseURL = "https://dataservice.accuweather.com"
    
    private let keyCityName = "LocalizedName"
    private let keyCityID = "Key"
    
    private let keyAccuAPI = "aclG15Tu7dG0kikCCAYWL2TiCgNp6I6y"
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.autocompleteSearchBar.delegate = self
                
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setSearchBarFrame()
        
        self.setSearchTableViewFrame(keyboardShown: nil)
        self.searchTableView.rowHeight = CityTableViewCell.cellHeight
        self.searchTableView.separatorStyle = .none
        self.view.addSubview(self.searchTableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.autocompleteSearchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.autocompleteSearchBar.resignFirstResponder()
    }
    
    // MARK: - Initializers
    
    deinit {
        Manager.shared.citiesAutocompleteArray = []
    }
    
    // MARK: - IBAction
    
    @IBAction private func handle(keyboardNotification notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardRectangle = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            switch notification.name {
            case UIResponder.keyboardWillShowNotification:
                setSearchTableViewFrame(keyboardShown: true,
                                        keyboardHeight: keyboardRectangle.height,
                                        withDuration: animationDuration)
            default:
                setSearchTableViewFrame(keyboardShown: false)
            }
        }
    }
    
    // MARK: - Flow funcs
    
    func getLocation(complete: @escaping() -> ()) {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestLocation()
        guard let location = locationManager.location else { return }
        self.geopositionCity(for: location.coordinate) {
            complete()
        }
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setSearchBarFrame() {
        self.autocompleteSearchBar.frame = CGRect(x: 0,
                                                  y: self.view.safeAreaInsets.top,
                                                  width: self.view.frame.size.width,
                                                  height: self.autocompleteSearchBarHeight)
        self.view.addSubview(self.autocompleteSearchBar)
    }
    
    private func setSearchTableViewFrame(keyboardShown: Bool?,
                                         keyboardHeight: CGFloat = 0,
                                         withDuration duration: TimeInterval = 0) {
        var height: CGFloat = self.view.frame.size.height - self.autocompleteSearchBarHeight - self.view.safeAreaInsets.top
        if let keyboardShown = keyboardShown, keyboardShown {
            height -= keyboardHeight
        } else if let keyboardShown = keyboardShown, !keyboardShown || self.searchTableView.frame == CGRect() {
            height -= self.view.safeAreaInsets.bottom
        } else {
            return
        }
        UIView.animate(withDuration: duration) {
            self.searchTableView.frame = CGRect(x: 0,
                                                y: self.view.safeAreaInsets.top + self.autocompleteSearchBarHeight,
                                                width: self.view.frame.size.width,
                                                height: height)
        }
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Server connection functions
    
    func autocomplete(for text: String, complete: @escaping () -> ()) {
        let urlString = "\(self.baseURL)/locations/v1/cities/autocomplete?apikey=\(self.keyAccuAPI)&q=\(text)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let cityDataArray = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String : Any]]
            guard let parsedCityArray = self.parseCityAutocompleteArray(from: cityDataArray) else { return }
            Manager.shared.citiesAutocompleteArray = parsedCityArray
            DispatchQueue.main.async {
                complete()
            }
        }.resume()
    }
    
    private func geopositionCity(for location: CLLocationCoordinate2D, complete: @escaping () -> ()) {
        let urlString = "\(self.baseURL)/locations/v1/cities/geoposition/search?apikey=\(self.keyAccuAPI)&q=\(location.latitude),\(location.longitude)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let newCity = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]
            guard let parsedCity = self.parseGeopositionCity(from: newCity) else { return }
            if Manager.shared.citiesArray.first?.isLocated == true {
                Manager.shared.citiesArray.removeFirst()
            }
            Manager.shared.citiesArray.insert(parsedCity, at: 0)
            DispatchQueue.main.async {
                complete()
            }
        }.resume()
    }
    
    private func parseCityAutocompleteArray(from dataArray: [[String : Any]]?) -> [CityAutocomplete]? {
        guard let dataArray = dataArray else { return nil }
        var cityArray: [CityAutocomplete] = []
        for dataDictionary in dataArray {
            if let id = dataDictionary[self.keyCityID] as? String,
               let name = dataDictionary[self.keyCityName] as? String {
                cityArray.append(CityAutocomplete(id: id, name: name))
            }
        }
        return cityArray
    }
    
    private func parseGeopositionCity(from dataDictionary: [String : Any]?) -> City? {
        guard let dataDictionary = dataDictionary else { return nil }
        guard let id = dataDictionary[self.keyCityID] as? String else { return nil }
        guard let name = dataDictionary[self.keyCityName] as? String else { return nil }
        let newCity = City(id: id, name: name, isLocated: true)
        return newCity
    }
    
}
