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
    
    //    var currentCityIndex = 0 {
    //        didSet {
    //            self.pageControl.currentPage = self.currentCityIndex
    //        }
    //    }
    private let gradient = CAGradientLayer()
    
    private let pageControl = UIPageControl()
    private let pageControlHeight: CGFloat = 20
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        self.defaultNavigationBarBackground()
        
        self.createListButton()
        self.view.addSubview(pageControl)
        self.addGradient()
        
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
        
        self.updatePageControl()
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
        list.delegate = self
        self.navigationController?.pushViewController(list, animated: true)
    }
    
    
    // MARK: - Flow funcs
    
    
    
    func showCityViewController(withIndex index: Int) {
        guard let controller = self.cityViewController(withIndex: index) else { return }
        
        self.selectViewController(controller, direction: .forward, animated: true, completion: nil)
        
    }
    
    func cityViewController(withIndex i: Int) -> CityViewController? {
        
        var index = i
        let citiesCount = Manager.shared.citiesArray.count
                
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
        self.updatePageControl(index: index)
        self.navigationController?.popToRootViewController(animated: true)
        self.showCityViewController(withIndex: index)
    }
    
    func checkDeletedViewControllers() {
        
        guard let controller = self.selectedViewController as? CityViewController else { return }
        let city = controller.city
        var index: Int
        
        if let i = Manager.shared.citiesArray.firstIndex(of: city) {
            index = i
        } else {
            index = self.pageControl.currentPage
        }
        
        self.updateFrame()
        
        self.updatePageControl(index: index)
        self.showCityViewController(withIndex: self.pageControl.currentPage)
        
    }
    
    func updateFrame() {
        self.view.frame.size.height += self.view.frame.origin.y
        self.view.frame.origin.y = 0
    }
    
    func configurePageControl() {
        self.pageControl.frame = CGRect(x: 0,
                                        y: self.view.safeAreaInsets.top,
                                        width: self.view.frame.width,
                                        height: self.pageControlHeight) //=================================================================
        self.pageControl.numberOfPages = Manager.shared.citiesArray.count
        self.pageControl.isUserInteractionEnabled = false //=====================================================================================
        self.pageControl.hidesForSinglePage = true
        
    }
    
    func updatePageControl(index: Int? = nil) {
        pageControl.numberOfPages = Manager.shared.citiesArray.count
        if let index = index {
            self.pageControl.currentPage = index
        }
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
        self.changeGradientColor()
    }
    
    func changeGradientColor(isDayTime: Bool = true) {
        if isDayTime {
            self.gradient.colors = [UIColor(red: 1, green: 0.7, blue: 0.48, alpha: 1).cgColor,
                                    UIColor(red: 1, green: 0.49, blue: 0.49, alpha: 1).cgColor,
                                    UIColor(red: 1, green: 0.82, blue: 0.24, alpha: 1).cgColor]
        } else {
            self.gradient.colors = [UIColor(red: 0.25, green: 0, blue: 0.57, alpha: 1).cgColor,
                                    UIColor(red: 0, green: 0.35, blue: 0.53, alpha: 1).cgColor,
                                    UIColor(red: 0.02, green: 0, blue: 0.36, alpha: 1).cgColor]
        }
    }
    
}



