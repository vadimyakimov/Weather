//
//  ViewController.swift
//  Weather 2
//
//  Created by Вадим on 11.01.2022.
//

import UIKit
import EMPageViewController

class CitiesPageViewController: EMPageViewController {
    
    // MARK: - Properties
    
    var citiesArray: [City] {
        get {
            if let data = UserDefaults.standard.data(forKey: self.citiesArrayKeyUserDefaults),
               let decoded = try? JSONDecoder().decode([City].self, from: data) {
                return decoded
            }

            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: self.citiesArrayKeyUserDefaults)
            }
        }
    }
    
    private let citiesArrayKeyUserDefaults = "CitiesArray"
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private let gradient = CAGradientLayer()
    
    var nameLabel = UILabel()
    var newNameLabel = UILabel()
    let nameLabelHeight: CGFloat = 80
    let nameLabelFontSize: CGFloat = 60
    let nameLabelMinimumFontSize: CGFloat = 30
    
    private let pageControl = UIPageControl()
    private let pageControlHeight: CGFloat = 20
    
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        self.defaultNavigationBarBackground()
        
        self.view.addSubview(pageControl)
        self.addGradient()
        
        if self.citiesArray.count > 0 {
            self.showCityViewController(withIndex: 0)
        } else {
            let searchScreen = SearchScreenViewController()
            searchScreen.delegate = self
            self.navigationController?.pushViewController(searchScreen, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.updatePageControl()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        self.configurePageControl()
        self.addListButton()
        
        self.addNameLabel()  //========
        
        self.view.addSubview(self.nameLabel)
        self.view.addSubview(self.newNameLabel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    
    
    
    
    // MARK: - IBActions
    
    @IBAction func listButtonPressed() {
        let list = CitiesListViewController(citiesList: self.citiesArray)
        list.delegate = self
        self.navigationController?.pushViewController(list, animated: true)
    }
    
    
    // MARK: - Flow funcs
    
    
    
    func showCityViewController(withIndex index: Int) {
        guard let controller = self.cityViewController(withIndex: index) else { return }
        
        self.selectViewController(controller, direction: .forward, animated: true, completion: nil)
        
        self.changeGradientColor(isDayTime: controller.city.currentWeather?.isDayTime)
    }
    
    func cityViewController(withIndex i: Int) -> CityViewController? {
        
        var index = i
        let citiesCount = self.citiesArray.count
                
        if index < 0 {
            if citiesCount > 3 {
                index += citiesCount
            } else {
                return nil
            }
        } else if index >= citiesCount {
            if citiesCount > 3 {
                index -= citiesCount
            } else {
                return nil
            }
        }
        
        let cityViewController = CityViewController(self.citiesArray[index] )
        cityViewController.delegate = self
        return cityViewController
    }
    
    func backToPageViewController(withIndex index: Int) {
        self.updatePageControl(index: index)
        self.navigationController?.popToRootViewController(animated: true)
        self.showCityViewController(withIndex: index)
    }
    
    func checkDeletedViewControllers() {
        
        guard let controller = self.selectedViewController as? CityViewController else { return }
        let city = controller.city
        var index: Int
        
        if let i = self.citiesArray.firstIndex(of: city) {
            index = i
        } else {
            index = self.pageControl.currentPage
        }
        
        self.updateFrame()
        
        self.updatePageControl(index: index)
        self.showCityViewController(withIndex: self.pageControl.currentPage)
        
    }
    
    func updateCity(_ city: City) {
        guard let index = self.citiesArray.firstIndex(of: city) else { return }
        self.citiesArray[index] = city
    }
    
    private func updateFrame() {
        self.view.frame.size.height += self.view.frame.origin.y
        self.view.frame.origin.y = 0
    }
    
    func configurePageControl() {
        self.pageControl.frame = CGRect(x: 0,
                                        y: self.view.safeAreaInsets.top,
                                        width: self.view.frame.width,
                                        height: self.pageControlHeight) //=================================================================
        self.pageControl.numberOfPages = self.citiesArray.count
        self.pageControl.isUserInteractionEnabled = false //=====================================================================================
        self.pageControl.hidesForSinglePage = true
    }
    
    func updatePageControl(index: Int? = nil) {
        pageControl.numberOfPages = self.citiesArray.count
        if let index = index {
            self.pageControl.currentPage = index
        }
    }
    
    private func addNameLabel() {
        
        guard let controller = self.selectedViewController as? CityViewController else { return }
        
        self.configureNameLabel(self.nameLabel, text: controller.city.name)
        self.view.addSubview(self.nameLabel)
        
        self.configureNameLabel(self.newNameLabel)
        self.view.addSubview(self.newNameLabel)
    }
    
    private func configureNameLabel(_ nameLabel: UILabel, text: String = "") {
        
        let screen = self.view.frame.size
        let horizontalOffsets: CGFloat = 0
        
        nameLabel.frame = CGRect(x: horizontalOffsets,
                                 y: self.view.safeAreaInsets.top + self.pageControlHeight,
                                 width: screen.width - (horizontalOffsets * 2),
                                 height: self.nameLabelHeight)
        nameLabel.textColor = .white
        nameLabel.text = text
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: self.nameLabelFontSize, weight: .light)
        nameLabel.layer.zPosition = 100
        nameLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func addListButton() { //====================
        
        let listImage = UIImage(named: "menu")
        
        let listImageView = UIImageView(frame: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: 44, height: 44))
        listImageView.image = listImage
        listImageView.isUserInteractionEnabled = true
//        listImageView.backgroundColor = .yellow
        
        self.view.addSubview(listImageView)
        
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(self.listButtonPressed))
        listImageView.addGestureRecognizer(recognizer)
    }
    
    private func defaultNavigationBarBackground() {
//                self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//                self.navigationController?.navigationBar.shadowImage = UIImage()
//                self.navigationController?.navigationBar.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            self.navigationController?.view.backgroundColor = .systemBackground
        }
    }
    
    private func addGradient() {
        self.gradient.opacity = 1
        self.gradient.startPoint = CGPoint(x: 0, y: 0)
        self.gradient.endPoint = CGPoint(x: 0, y: 1)
        self.gradient.frame = self.view.bounds
        self.view.layer.insertSublayer(gradient, at: 0)
        
        self.changeGradientColor(isDayTime: nil)
    }
    
    func changeGradientColor(isDayTime: Bool?) {
        if isDayTime == false {
            self.gradient.colors = [UIColor(red: 0.25, green: 0, blue: 0.57, alpha: 1).cgColor,
                                    UIColor(red: 0, green: 0.35, blue: 0.53, alpha: 1).cgColor,
                                    UIColor(red: 0.02, green: 0, blue: 0.36, alpha: 1).cgColor]
        } else {
            self.gradient.colors = [UIColor(red: 1, green: 0.7, blue: 0.48, alpha: 1).cgColor,
                                    UIColor(red: 1, green: 0.49, blue: 0.49, alpha: 1).cgColor,
                                    UIColor(red: 1, green: 0.82, blue: 0.24, alpha: 1).cgColor]
        }
    }
    
}



