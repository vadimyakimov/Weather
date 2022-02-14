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
    let autocompleteSearchController = UISearchController()
    lazy var locationManager = CLLocationManager()
    lazy var autocompleteTimer = Timer()
        
    // API keys
    
    private let baseURL = "https://dataservice.accuweather.com"
    private let language = "language=" + "en-us".localized()
    private let keyAccuAPI = "pUPRp5bjAvEajZjEA6kc6yPSlbYMhXRZ"
    
    private let keyCityName = "LocalizedName"
    private let keyCityID = "Key"
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForKeyboardNotifications()
        
        
        self.addSearchController()
        self.addSearchTableView()
        self.addNavigationControllerBackground()
        self.addStatusBarBackground()
        
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
//        self.addSearchTableView()
        
//        updateSearchTableViewFrame() //==========
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        self.autocompleteSearchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.autocompleteSearchController.searchBar.resignFirstResponder()
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
            
            var isKeyboardShown: Bool
            
            switch notification.name {
            case UIResponder.keyboardWillShowNotification:
                isKeyboardShown = true
            default:
                isKeyboardShown = false
            }
            
            updateSearchTableViewFrame(keyboardShown: isKeyboardShown,
                                       keyboardHeight: keyboardRectangle.height,
                                       withDuration: animationDuration)
        }
    }
    
    // MARK: - Flow funcs
    
        
    private func addSearchController() {
        self.autocompleteSearchController.searchResultsUpdater = self
        self.searchTableView.tableHeaderView = self.autocompleteSearchController.searchBar
        self.autocompleteSearchController.hidesNavigationBarDuringPresentation = false
        self.autocompleteSearchController.searchBar.becomeFirstResponder()
        
        if #available(iOS 13.0, *) {
            self.searchTableView.tableHeaderView?.backgroundColor = .yellow
        } else {
            self.searchTableView.tableHeaderView?.backgroundColor = .white
        }
        
        self.autocompleteSearchController.definesPresentationContext = true
        self.definesPresentationContext = true
    }
    
    private func addSearchTableView() {
        
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        
        self.searchTableView.frame = self.view.bounds //=======
        
        
        self.searchTableView.rowHeight = CityTableViewCell.cellHeight
        self.searchTableView.separatorStyle = .none
        searchTableView.scrollIndicatorInsets.top = self.autocompleteSearchController.searchBar.frame.height
        self.view.addSubview(self.searchTableView)
    }
    
    private func updateSearchTableViewFrame(keyboardShown: Bool,
                                            keyboardHeight: CGFloat,
                                            withDuration duration: TimeInterval) {
        var height = self.view.frame.height
        
        if keyboardShown == true {
            height -= keyboardHeight
        }

        UIView.animate(withDuration: duration) {
            self.searchTableView.frame.size.height = height
        }
        self.view.layoutIfNeeded()
    }
    
    func requestLocation() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer   
        self.locationManager.requestLocation()
    }
    
    func showLocationErrorAlert() {
        
        let errorTitle = "Failed to find your location".localized()
        let errorMessage = "Check if your location is allowed in the settings, or try again later".localized()
        
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings".localized(), style: .default) { action in
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    func startLoadingAnimation() {
        guard let cell = searchTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CityTableViewCell else { return }
        cell.startLoading()
    }
    
    func stopLoadingAnimation() {
        guard let cell = searchTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CityTableViewCell else { return }
        cell.stopLoading() 
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addNavigationControllerBackground() {
        let statusBarFrame = UIApplication.shared.statusBarFrame
        var frame = statusBarFrame
        
        if let navigationController = self.navigationController {
            let navigationBarFrame = navigationController.navigationBar.frame
            frame.size.height += navigationBarFrame.height
            frame.origin.y -= navigationBarFrame.height
            if navigationController.isNavigationBarHidden == false {
                frame.origin.y -= statusBarFrame.height
            }
        }
        
        let view = UIView(frame: frame)
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.blue
        } else {
            view.backgroundColor = UIColor.white
        }
        self.view.addSubview(view)
    }
    
    private func addStatusBarBackground() {
//        let frame = UIApplication.shared.statusBarFrame
//        let view = UIView(frame: frame)
//        if #available(iOS 13.0, *) {
//            view.backgroundColor = .blue
//        } else {
//            view.backgroundColor = .white
//        }
//        self.navigationController?.view.addSubview(view)
    }
    
    // MARK: - Server connection functions
    
    func autocomplete(for text: String, complete: @escaping () -> ()) {
        guard let encodedText = (text as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            
        let urlString = "\(self.baseURL)/locations/v1/cities/autocomplete?apikey=\(self.keyAccuAPI)&q=\(encodedText)&\(self.language)"
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
    
    func geopositionCity(for location: CLLocationCoordinate2D, complete: @escaping (City) -> ()) {
        let urlString = "\(self.baseURL)/locations/v1/cities/geoposition/search?apikey=\(self.keyAccuAPI)&q=\(location.latitude),\(location.longitude)&\(self.language)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            let newCity = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]
            guard let parsedCity = self.parseGeopositionCity(from: newCity) else { return }
            
            DispatchQueue.main.async {
                complete(parsedCity)
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
