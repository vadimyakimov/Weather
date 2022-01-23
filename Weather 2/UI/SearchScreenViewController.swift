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
    let searchRowHeight: CGFloat = 60
    let searchCellId = "autocompleteCell"
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.autocompleteSearchBar.delegate = self
        
        self.searchTableView.register(CityTableViewCell.self, forCellReuseIdentifier: self.searchCellId)
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.backgroundColor = .white
        
        self.setSearchBarFrame()
        self.view.addSubview(self.autocompleteSearchBar)
        
        self.setSearchTableViewFrame(keyboardShown: nil)
        self.searchTableView.rowHeight = self.searchRowHeight
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
        Manager.shared.geopositionCity(for: location.coordinate) {
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
}
