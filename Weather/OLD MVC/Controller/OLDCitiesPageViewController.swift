//import UIKit
//import EMPageViewController
//import CoreData
//
//class OLDCitiesPageViewController: EMPageViewController {
//    
//    // MARK: - Properties
//    
//    private let viewModel = CitiesPageViewModel()
//                
//    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
//    
//    private let gradient = CAGradientLayer()
//    
//    var nameLabel = UILabel()
//    var newNameLabel = UILabel()
//    private let nameLabelHeight: CGFloat = 80
//    let nameLabelFontSize: CGFloat = 60
//    let nameLabelMinimumFontSize: CGFloat = 30
//    let horizontalOffset: CGFloat = 20
//    
//    private let pageControl = UIPageControl()
//    private let pageControlHeight: CGFloat = 20
//    private var previousPageControlIndex: Int?
//    
//        
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//            
//        self.dataSource = self
//        self.delegate = self
//        self.scrollView.contentInsetAdjustmentBehavior = .never
//        
//        self.addGradient()
//        self.view.addSubview(self.pageControl)
//        
////        self.
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        self.updatePageControl()
//        self.navigationController?.isNavigationBarHidden = true
//    }
//    
//    override func viewSafeAreaInsetsDidChange() {
//        super.viewSafeAreaInsetsDidChange()
//        
//        self.configurePageControl()
//        self.addNameLabel()
//        
//    }
//        
//    // MARK: - IBActions
//    
//    @IBAction func listButtonPressed() {
//        let list = CitiesListViewController()
//        list.delegate = self
//        self.navigationController?.pushViewController(list, animated: true)
//    }
//    
//    @IBAction func pageControlValueChanged(_ sender: Any) {
//        guard let pageControl = sender as? UIPageControl else { return }
//        
//        if pageControl.isSelected {
//            return
//        } else {
//            self.pageControl(didUpdate: pageControl)
//        }
//    }
//    
//    @IBAction func pageControlTouchDown(_ sender: Any) {
//        guard let pageControl = sender as? UIPageControl else { return }
//        pageControl.isSelected = true
//        self.previousPageControlIndex = pageControl.currentPage
//    }
//    
//    @IBAction func pageControlTouchUp(_ sender: Any) {
//        guard let pageControl = sender as? UIPageControl else { return }
//        pageControl.isSelected = false
//        self.pageControl(didUpdate: pageControl)
//    }
//    
//    // MARK: - View Controllers Management
//    
//    func showCityViewController(withIndex index: Int, direction: EMPageViewControllerNavigationDirection = .forward) {
//        guard let controller = self.cityViewController(withIndex: index) else { return }
//        
//        self.selectViewController(controller, direction: direction, animated: true, completion: nil)
//        self.changeGradientColor(isDayTime: controller.city.currentWeather?.isDayTime)
//    }
//    
//    func cityViewController(withIndex i: Int) -> CityViewController? {
//                
//        var index = i
//        let citiesCount = CitiesCoreDataStack.shared.citiesList.count
//                
//        if index < 0 {
//            if citiesCount > 3 {
//                index += citiesCount
//            } else {
//                return nil
//            }
//        } else if index >= citiesCount {
//            if citiesCount > 3 {
//                index -= citiesCount
//            } else {
//                return nil
//            }
//        }
//        
//        let yOriginCityViewController = self.nameLabelHeight + self.pageControlHeight
//        let cityViewController = CityViewController(CitiesCoreDataStack.shared.citiesList[index],
//                                                    frame: CGRect(x: 0,
//                                                                  y: yOriginCityViewController,
//                                                                  width: self.view.frame.size.width,
//                                                                  height: self.view.frame.size.height - yOriginCityViewController))
//        cityViewController.delegate = self
//        return cityViewController
//    }
//    
//    func backToPageViewController(withIndex index: Int) {
//        self.navigationController?.popToRootViewController(animated: true)
//        self.updatePageControl(index: index)
//        self.showCityViewController(withIndex: index)
//    }
//    
//    func checkDeletedViewControllers() {
//        
//        guard self.navigationController?.topViewController == self,
//            let controller = self.selectedViewController as? CityViewController else { return }
//        
//        
//        let city = controller.city
//        var index: Int
//        
//        if let i = CitiesCoreDataStack.shared.citiesList.firstIndex(of: city) {
//            index = i
//        } else {
//            index = self.pageControl.currentPage
//        }
//        
//        self.updateFrame()
//        
//        self.updatePageControl(index: index)
//        self.showCityViewController(withIndex: self.pageControl.currentPage)
//    }
//    
//    // MARK: - Frame
//    
//    private func updateFrame() {
//        self.view.frame.size.height += self.view.frame.origin.y
//        self.view.frame.origin.y = 0
//    }
//        
//    // MARK: - Page Control
//    
//    private func configurePageControl() {
//        self.updatePageControl()
//        self.pageControl.frame.origin = CGPoint(x: (self.view.frame.width - self.pageControl.frame.width) / 2,
//                                                y: self.view.safeAreaInsets.top)
//        self.pageControl.hidesForSinglePage = true
//        
//        self.pageControl.addTarget(self, action: #selector(self.pageControlValueChanged(_:)), for: .valueChanged)
//        self.pageControl.addTarget(self, action: #selector(self.pageControlTouchDown(_:)), for: .touchDown)
//        self.pageControl.addTarget(self, action: #selector(self.pageControlTouchUp(_:)), for: [.touchUpInside])
//    }
//    
//    func updatePageControl(index: Int? = nil) {
//        if self.pageControl.numberOfPages != CitiesCoreDataStack.shared.citiesList.count {
//            self.pageControl.numberOfPages = CitiesCoreDataStack.shared.citiesList.count
//            let size = self.pageControl.size(forNumberOfPages: self.pageControl.numberOfPages)
//            self.pageControl.frame.size = CGSize(width: size.width, height: self.pageControlHeight)
//            self.pageControl.frame.origin.x = (self.view.frame.width - size.width) / 2
//        }
//        
//        if let index = index {
//            self.pageControl.currentPage = index
//        }
//    }
//    
//    func pageControl(didUpdate pageControl: UIPageControl) {
//        guard let previousPageControlIndex = self.previousPageControlIndex,
//                pageControl.currentPage != previousPageControlIndex,
//                !pageControl.isSelected else { return }
//        
//        if pageControl.currentPage > previousPageControlIndex {
//            showCityViewController(withIndex: pageControl.currentPage, direction: .forward)
//        } else {
//            showCityViewController(withIndex: pageControl.currentPage, direction: .reverse)
//        }
//    }
//    
//    // MARK: - Name Label
//    
//    private func addNameLabel() {
//        
//        guard let controller = self.selectedViewController as? CityViewController else { return }
//                
//        self.configureNameLabel()
//        self.view.addSubview(self.newNameLabel)
//        
//        self.configureNameLabel(text: controller.city.name)
//        self.view.addSubview(self.nameLabel)
//        
//        let recognizer = UITapGestureRecognizer(target: self,
//                                                action: #selector(self.listButtonPressed))
//        self.nameLabel.addGestureRecognizer(recognizer)
//    }
//    
//    private func configureNameLabel(text: String? = nil) {
//        
//        let screen = self.view.frame.size
//        
//        self.newNameLabel.frame = CGRect(x: self.horizontalOffset,
//                                         y: self.view.safeAreaInsets.top + self.pageControlHeight,
//                                         width: screen.width - (self.horizontalOffset * 2),
//                                         height: self.nameLabelHeight)
//        self.newNameLabel.text = text
//        self.newNameLabel.textColor = .white
//        self.newNameLabel.textAlignment = .center
//        self.newNameLabel.font = UIFont.systemFont(ofSize: self.nameLabelFontSize, weight: .light)
//        self.newNameLabel.layer.zPosition = 100
//        self.newNameLabel.adjustsFontSizeToFitWidth = true
//        self.newNameLabel.isUserInteractionEnabled = true
//    }
//    
//    // MARK: - Background Gradient
//    
//    private func addGradient() {
//        self.gradient.opacity = 1
//        self.gradient.startPoint = CGPoint(x: 0, y: 0)
//        self.gradient.endPoint = CGPoint(x: 0, y: 1)
//        self.gradient.frame = self.view.bounds
//        self.view.layer.insertSublayer(gradient, at: 0)
//        
//        self.changeGradientColor(isDayTime: nil)
//    }
//    
//    func changeGradientColor(isDayTime: Bool?) {
//        if isDayTime == false {
//            self.gradient.colors = [UIColor(red: 0.25, green: 0, blue: 0.57, alpha: 1).cgColor,
//                                    UIColor(red: 0, green: 0.35, blue: 0.53, alpha: 1).cgColor,
//                                    UIColor(red: 0.02, green: 0, blue: 0.36, alpha: 1).cgColor]
//        } else {
//            self.gradient.colors = [UIColor(red: 1, green: 0.7, blue: 0.48, alpha: 1).cgColor,
//                                    UIColor(red: 1, green: 0.49, blue: 0.49, alpha: 1).cgColor,
//                                    UIColor(red: 1, green: 0.82, blue: 0.24, alpha: 1).cgColor]
//        }
//    }
//    
//}
//
//
//
