//
//  ViewController.swift
//  Weather 2
//
//  Created by Вадим on 11.01.2022.
//

import UIKit

class CitiesPageViewController: UIPageViewController {
    
    // MARK: - Properties
    
    var currentCityIndex = 0 {
        didSet {
            self.pageControl.currentPage = self.currentCityIndex
        }
    }
    let pageControl = UIPageControl()
    let pageControlHeight: CGFloat = 20
    
    let gradient = CAGradientLayer()
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        
        if Manager.shared.citiesArray.count > 0 {
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
        
        self.createListButton()
        self.defaultNavigationBarBackground()
        
        self.view.layer.insertSublayer(gradient, at: 0)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self.configurePageControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func listButtonPressed() {
        let list = CitiesListViewController()
        list.searchScreen.delegate = self
        list.delegate = self
        self.navigationController?.pushViewController(list, animated: true)
    }
    
    
    // MARK: - Flow funcs
    
    func showCityViewController(withIndex index: Int) {
        guard let controller = self.cityViewController(withIndex: index) else { return }
        
        
        //==========================================
        if let previous = pageViewController(self, viewControllerBefore: controller) {
            self.setViewControllers([previous], direction: .forward, animated: true)
        }
        
        self.setViewControllers([controller], direction: .forward, animated: true)
    }
    
    func cityViewController(withIndex i: Int) -> CityViewController? {
        
        var index = i
        let citiesCount = Manager.shared.citiesArray.count
        
        guard citiesCount > 1 else { return nil }
        
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
                
        let cityViewController = CityViewController(Manager.shared.citiesArray[index])
        cityViewController.delegate = self
        return cityViewController
    }
    
    func backToPageViewController(withIndex index: Int) {
//        self.currentCityIndex = index
        self.pageControl.currentPage = index
        self.navigationController?.popToRootViewController(animated: true)
        self.showCityViewController(withIndex: index)
    }
    
    func configurePageControl() {
        self.pageControl.frame = CGRect(x: 0,
                                        y: self.view.safeAreaInsets.top,
                                        width: self.view.frame.width,
                                        height: self.pageControlHeight) //=================================================================
        self.pageControl.numberOfPages = Manager.shared.citiesArray.count
        self.pageControl.isUserInteractionEnabled = false //=====================================================================================
        self.pageControl.hidesForSinglePage = true
        self.view.addSubview(pageControl)
    }
    
    func updatePageControl(index: Int) {
        
    }
    
    private func createListButton() { //====================
        let listButton = UIButton(frame: CGRect(x: 0, y: 50, width: 60, height: 60))
        listButton.backgroundColor = .yellow
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(self.listButtonPressed))
        listButton.addGestureRecognizer(recognizer)
        self.view.addSubview(listButton)
    }
    
    private func defaultNavigationBarBackground() {
//        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = false
                
        if #available(iOS 13.0, *) {
            self.navigationController?.view.backgroundColor = .systemBackground
        }
    }
    
    func addGradient(isDayTime: Bool) {        
        if isDayTime {
            self.gradient.colors = [UIColor(red: 1, green: 0.7, blue: 0.48, alpha: 1).cgColor,
                               UIColor(red: 1, green: 0.49, blue: 0.49, alpha: 1).cgColor,
                               UIColor(red: 1, green: 0.82, blue: 0.24, alpha: 1).cgColor]
        } else {
            self.gradient.colors = [UIColor(red: 0.02, green: 0, blue: 0.36, alpha: 1).cgColor,
                               UIColor(red: 0.15, green: 0, blue: 0.37, alpha: 1).cgColor,
                               UIColor(red: 0, green: 0.45, blue: 0.53, alpha: 1).cgColor]
        }
        self.gradient.opacity = 1
        self.gradient.startPoint = CGPoint(x: 0, y: 0)
        self.gradient.endPoint = CGPoint(x: 0, y: 1)
        self.gradient.frame = self.view.bounds
    }

}



