import UIKit
import CoreLocation
import CoreData


class SearchScreenViewController: UIViewController {
    
    
    // MARK: - Properties
    
    weak var delegate: SearchScreenViewControllerDelegate?
    
    lazy var context = CoreDataStack().persistentContainer.viewContext
    
    var citiesAutocompleteArray: [City]?
    
    var searchTableView = UITableView()
    let autocompleteSearchController = UISearchController()
    lazy var locationManager = CLLocationManager()
    lazy var autocompleteTimer = Timer()
    
    let hidesBackButton: Bool
        
    // API keys
    
    private let baseURL = "https://dataservice.accuweather.com"
    private let language = "language=" + "en-us".localized()
    private let keyAccuAPI = "dcXaSaOT2bTNKzDiMD37dnGlZXGEeTxG"
    
    private let keyCityName = "LocalizedName"
    private let keyCityID = "Key"
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForKeyboardNotifications()
        
        self.addSearchController()
        self.addSearchTableView()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.autocompleteSearchController.isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    // MARK: - Initializers
    
    init(hidesBackButton: Bool = false) {
        self.hidesBackButton = hidesBackButton
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    // MARK: - NotificationCenter funcs
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - UI configuration funcs
    
    private func addSearchController() {        
        self.autocompleteSearchController.searchResultsUpdater = self
        self.autocompleteSearchController.delegate = self
        
        if self.hidesBackButton {
            self.navigationItem.titleView = self.autocompleteSearchController.searchBar
            self.navigationItem.hidesBackButton = true
            self.autocompleteSearchController.hidesNavigationBarDuringPresentation = false
        } else {
            self.navigationItem.searchController = self.autocompleteSearchController
        }
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func addSearchTableView() {
        
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        
        self.searchTableView.frame = self.view.bounds
        self.searchTableView.rowHeight = CityTableViewCell.cellHeight
        self.searchTableView.separatorStyle = .none
        self.view.addSubview(self.searchTableView)
    }
    
    private func updateSearchTableViewFrame(keyboardShown: Bool,
                                            keyboardHeight: CGFloat,
                                            withDuration duration: TimeInterval) {
        var height = self.view.frame.height
        
        if keyboardShown == true {
            height -= keyboardHeight
            if let navigationBarHeight = self.navigationController?.navigationBar.frame.height {
                height += navigationBarHeight
                height -= self.autocompleteSearchController.searchBar.frame.height
            }
        }
        
        UIView.animate(withDuration: duration) {
            self.searchTableView.frame.size.height = height
        }
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Location funcs
    
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
    
    // MARK: - Server connection functions
    
    func autocomplete(for text: String, complete: @escaping () -> ()) {
        guard let encodedText = (text as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            
        let urlString = "\(self.baseURL)/locations/v1/cities/autocomplete?apikey=\(self.keyAccuAPI)&q=\(encodedText)&\(self.language)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let cityDataArray = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String : Any]]
            guard let parsedCityArray = self.parseCityAutocompleteArray(from: cityDataArray) else { return }
            self.citiesAutocompleteArray = parsedCityArray
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
    
    private func parseCityAutocompleteArray(from dataArray: [[String : Any]]?) -> [City]? {
        guard let dataArray = dataArray else { return nil }
        
        var autocompletedCitiesArray: [City] = []
        
        for dataDictionary in dataArray {
            if let key = dataDictionary[self.keyCityID] as? String,
               let name = dataDictionary[self.keyCityName] as? String {
                
                let city = City(context: self.context, key: key, name: name)
                autocompletedCitiesArray.append(city)
            }
        }
        return autocompletedCitiesArray
    }
    
    private func parseGeopositionCity(from dataDictionary: [String : Any]?) -> City? {
        guard let dataDictionary = dataDictionary else { return nil }
        guard let key = dataDictionary[self.keyCityID] as? String else { return nil }
        guard let name = dataDictionary[self.keyCityName] as? String else { return nil }
        
        let city = City(context: self.context, key: key, name: name, isLocated: true)
        
        return city
    }
    
}
