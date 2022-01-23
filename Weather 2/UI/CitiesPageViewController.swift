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
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                                
        self.dataSource = self
        self.delegate = self
        
//        self.createListButton()
//        self.defaultNavigationBarBackground()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        
        if Manager.shared.citiesArray.count > 0 {
            self.createCityViewController()
        } else {
            let searchScreen = SearchScreenViewController()
            searchScreen.delegate = self
            self.navigationController?.pushViewController(searchScreen, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if Manager.shared.citiesArray.count > 1 {
            self.pageControl.frame = CGRect(x: 0,
                                            y: self.view.safeAreaInsets.top,
                                            width: self.view.frame.width,
                                            height: self.pageControlHeight)
            self.pageControl.numberOfPages = Manager.shared.citiesArray.count
            self.pageControl.isUserInteractionEnabled = false //================================
            self.view.addSubview(pageControl)
        }
    }
    
    
    // MARK: - IBActions
    
//    @IBAction func listButtonPressed() {
//        let list = CitiesListViewController()
//        list.searchScreen.delegate = self
//        list.delegate = self
//        self.navigationController?.pushViewController(list, animated: true)
//    }
    
    
    // MARK: - Flow funcs
    
    func createCityViewController() {
        let newCityViewController = CityViewController(index: self.currentCityIndex)
        newCityViewController.delegate = self
        self.setViewControllers([newCityViewController],
                                direction: .forward, animated: true, completion: nil)
    }
    
//    private func createListButton() {
//        let listButton = UIButton(frame: CGRect(x: 0, y: 50, width: 60, height: 60))
//        listButton.backgroundColor = .black
//        let recognizer = UITapGestureRecognizer(target: self,
//                                                action: #selector(self.listButtonPressed))
//        listButton.addGestureRecognizer(recognizer)
//        self.view.addSubview(listButton)
//    }
    
    private func defaultNavigationBarBackground() {
//        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = false
                
        if #available(iOS 13.0, *) {
            self.navigationController?.view.backgroundColor = .systemBackground
        }
    }
    
    func addGradient(isDayTime: Bool) {
        
        let gradient = CAGradientLayer()
        if isDayTime {
            gradient.colors = [UIColor(red: 1, green: 0.7, blue: 0.48, alpha: 1).cgColor,
                               UIColor(red: 1, green: 0.49, blue: 0.49, alpha: 1).cgColor,
                               UIColor(red: 1, green: 0.82, blue: 0.24, alpha: 1).cgColor]
        } else {
            gradient.colors = [UIColor(red: 0.02, green: 0, blue: 0.36, alpha: 1).cgColor,
                               UIColor(red: 0.15, green: 0, blue: 0.37, alpha: 1).cgColor,
                               UIColor(red: 0, green: 0.45, blue: 0.53, alpha: 1).cgColor]
        }
        gradient.opacity = 1
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)            
        gradient.frame = self.view.bounds
        self.view.layer.insertSublayer(gradient, at: 0)
    }

}



