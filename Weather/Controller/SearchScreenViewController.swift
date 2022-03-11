import UIKit
import CoreLocation
import CoreData


class SearchScreenViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: SearchScreenViewControllerDelegate?
    
    var citiesAutocompleteArray: [City]?
    
    let context = CoreDataStack().persistentContainer.viewContext
        
    var searchTableView = UITableView()
    let autocompleteSearchController = UISearchController()
    lazy var locationManager = CLLocationManager()
    lazy var autocompleteTimer = Timer()
    
    let hidesBackButton: Bool
    
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
    
}
