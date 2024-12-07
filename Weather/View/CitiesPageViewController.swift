//
//  CitiesPageViewController.swift
//  Weather
//
//  Created by Вадим on 03.12.2024.
//

import UIKit
import EMPageViewController

class CitiesPageViewController: EMPageViewController {
    
    // MARK: - Properties

    private let viewModel = CitiesPageViewModel()

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    private let backgroundGradient = CAGradientLayer()

    var nameLabel = UILabel()
    var newNameLabel = UILabel()
    private let nameLabelHeight: CGFloat = 80
    let nameLabelFontSize: CGFloat = 60
    let nameLabelMinimumFontSize: CGFloat = 30
    let horizontalOffset: CGFloat = 20

    private let pageControl = UIPageControl()
    private let pageControlHeight: CGFloat = 20
    private var previousPageControlIndex: Int?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        self.scrollView.contentInsetAdjustmentBehavior = .never

        self.addGradient()
        self.view.addSubview(self.pageControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updatePageControl()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        self.configurePageControl()
        self.addNameLabel()
    }
    
    // MARK: - Initializers
    
    init(atIndex index: Int) {
        super.init(nibName: nil, bundle: nil)
        self.showCityViewController(withIndex: index)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBActions

    @IBAction func listButtonPressed() {
//        let list = CitiesListViewController()
//        list.delegate = self
//        self.navigationController?.pushViewController(list, animated: true)
    }

    @IBAction func pageControlValueChanged(_ sender: Any) {
        guard let pageControl = sender as? UIPageControl else { return }

        if pageControl.isSelected {
            return
        } else {
            self.pageControl(didUpdate: pageControl)
        }
    }

    @IBAction func pageControlTouchDown(_ sender: Any) {
        guard let pageControl = sender as? UIPageControl else { return }
        pageControl.isSelected = true
        self.previousPageControlIndex = pageControl.currentPage
    }

    @IBAction func pageControlTouchUp(_ sender: Any) {
        guard let pageControl = sender as? UIPageControl else { return }
        pageControl.isSelected = false
        self.pageControl(didUpdate: pageControl)
    }
    
    // MARK: - View Controllers Management

    func showCityViewController(withIndex index: Int, direction: EMPageViewControllerNavigationDirection = .forward) {
        guard let controller = self.cityViewController(withIndex: index) else { return }

        self.selectViewController(controller, direction: direction, animated: true, completion: nil)
        self.changeGradientColor(isDayTime: controller.viewModel.city.currentWeather?.isDayTime)
    }

    func cityViewController(withIndex i: Int) -> CityViewController? {

        var index = i
        let citiesCount = self.viewModel.citiesCount

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

        let yOriginCityViewController = self.nameLabelHeight + self.pageControlHeight
        let cityViewController = CityViewController(self.viewModel.citiesList[index],
                                                    frame: CGRect(x: 0,
                                                                  y: yOriginCityViewController,
                                                                  width: self.view.frame.size.width,
                                                                  height: self.view.frame.size.height - yOriginCityViewController))
//        cityViewController.delegate = self
        return cityViewController
    }

//    func backToPageViewController(withIndex index: Int) {
//        self.navigationController?.popToRootViewController(animated: true)
//        self.updatePageControl(index: index)
//        self.showCityViewController(withIndex: index)
//    }
    
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
        
//  MARK: - Page Control
        
    private func configurePageControl() {
        self.updatePageControl()
        self.pageControl.frame.origin = CGPoint(x: (self.view.frame.width - self.pageControl.frame.width) / 2,
                                                y: self.view.safeAreaInsets.top)
        self.pageControl.hidesForSinglePage = true

        self.pageControl.addTarget(self, action: #selector(self.pageControlValueChanged(_:)), for: .valueChanged)
        self.pageControl.addTarget(self, action: #selector(self.pageControlTouchDown(_:)), for: .touchDown)
        self.pageControl.addTarget(self, action: #selector(self.pageControlTouchUp(_:)), for: [.touchUpInside])
    }

    func updatePageControl(index: Int? = nil) {
        if self.pageControl.numberOfPages != self.viewModel.citiesCount {
            self.pageControl.numberOfPages = self.viewModel.citiesCount
            let size = self.pageControl.size(forNumberOfPages: self.pageControl.numberOfPages)
            self.pageControl.frame.size = CGSize(width: size.width, height: self.pageControlHeight)
            self.pageControl.frame.origin.x = (self.view.frame.width - size.width) / 2
        }

        if let index = index {
            self.pageControl.currentPage = index
        }
    }

    func pageControl(didUpdate pageControl: UIPageControl) {
        guard let previousPageControlIndex = self.previousPageControlIndex,
              pageControl.currentPage != previousPageControlIndex,
              !pageControl.isSelected else { return }

        if pageControl.currentPage > previousPageControlIndex {
            showCityViewController(withIndex: pageControl.currentPage, direction: .forward)
        } else {
            showCityViewController(withIndex: pageControl.currentPage, direction: .reverse)
        }
    }

    // MARK: - Name Label

    private func addNameLabel() {

        guard let controller = self.selectedViewController as? CityViewController else { return }

        self.configureNameLabel(self.newNameLabel)
        self.view.addSubview(self.newNameLabel)

        self.configureNameLabel(self.nameLabel, text: controller.viewModel.city.name)
        self.view.addSubview(self.nameLabel)

        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(self.listButtonPressed))
        self.nameLabel.addGestureRecognizer(recognizer)
    }

    private func configureNameLabel(_ nameLabel: UILabel, text: String? = nil) {

        let screen = self.view.frame.size

        nameLabel.frame = CGRect(x: self.horizontalOffset,
                                         y: self.view.safeAreaInsets.top + self.pageControlHeight,
                                         width: screen.width - (self.horizontalOffset * 2),
                                         height: self.nameLabelHeight)
        nameLabel.text = text
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: self.nameLabelFontSize, weight: .light)
        nameLabel.layer.zPosition = 100
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.isUserInteractionEnabled = true
    }

    // MARK: - Background Gradient

    private func addGradient() {
        self.backgroundGradient.opacity = 1
        self.backgroundGradient.startPoint = CGPoint(x: 0, y: 0)
        self.backgroundGradient.endPoint = CGPoint(x: 0, y: 1)
        self.backgroundGradient.frame = self.view.bounds
        self.view.layer.insertSublayer(backgroundGradient, at: 0)
        self.changeGradientColor(isDayTime: self.viewModel.citiesList.first?.currentWeather?.isDayTime)
    }

    private func changeGradientColor(isDayTime: Bool?) {
        if isDayTime == false {
            self.backgroundGradient.colors = [UIColor(red: 0.25, green: 0, blue: 0.57, alpha: 1).cgColor,
                                    UIColor(red: 0, green: 0.35, blue: 0.53, alpha: 1).cgColor,
                                    UIColor(red: 0.02, green: 0, blue: 0.36, alpha: 1).cgColor]
        } else {
            self.backgroundGradient.colors = [UIColor(red: 1, green: 0.7, blue: 0.48, alpha: 1).cgColor,
                                    UIColor(red: 1, green: 0.49, blue: 0.49, alpha: 1).cgColor,
                                    UIColor(red: 1, green: 0.82, blue: 0.24, alpha: 1).cgColor]
        }
    }
}


// MARK: -
// MARK: - EM Page View Controller Data Source

extension CitiesPageViewController: EMPageViewControllerDataSource {
    
    func em_pageViewController(_ pageViewController: EMPageViewController,
                               viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        guard let controller = viewController as? CityViewController else { return nil }

        guard let index = self.viewModel.firstIndexInCityList(of: controller.viewModel.city) else { return nil }
        return self.cityViewController(withIndex: index - 1)
    }

    func em_pageViewController(_ pageViewController: EMPageViewController,
                               viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? CityViewController else { return nil }

        guard let index = self.viewModel.firstIndexInCityList(of: controller.viewModel.city) else { return nil }
        return self.cityViewController(withIndex: index + 1)
    }
}

// MARK: - EM Page View Controller Delegate

extension CitiesPageViewController: EMPageViewControllerDelegate {

    func em_pageViewController(_ pageViewController: EMPageViewController,
                               isScrollingFrom startingViewController: UIViewController,
                               destinationViewController: UIViewController, progress: CGFloat) {
        
        guard let destinationViewController = destinationViewController as? CityViewController,
              let startingViewController = startingViewController as? CityViewController else { return }
        

        var visibleViewController: CityViewController
        if abs(progress) > 0.5 {
            visibleViewController = destinationViewController
        } else {
            visibleViewController = startingViewController
        }
        let isDayTime = visibleViewController.viewModel.city.currentWeather?.isDayTime ?? true
        self.changeGradientColor(isDayTime: isDayTime)

        self.nameLabel.text = startingViewController.viewModel.city.name
        self.newNameLabel.text = destinationViewController.viewModel.city.name
        
        
        switch abs(progress) {
        case 0:
            self.newNameLabel.frame.origin.x = self.horizontalOffset + self.view.frame.width
        case 0..<1:
            let oldLabelGraph = -((pow(Double(progress), 3) / 2) + (progress / 2))
            let newLabelGraph = (abs(progress) / progress) * ((pow(Double(progress), 2) / 2) -
                                ((abs(progress) / progress) * progress * 1.5) + 1)

            self.nameLabel.frame.origin.x = self.horizontalOffset + (self.view.frame.width * oldLabelGraph)
            self.newNameLabel.frame.origin.x = self.horizontalOffset + (self.view.frame.width * newLabelGraph)


            let oldLabelOpacityGraph = -pow(Double(progress), 2) + 1
            let newLabelOpacityGraph = pow(progress, 2)

            self.nameLabel.layer.opacity = Float(oldLabelOpacityGraph)
            self.newNameLabel.layer.opacity = Float(newLabelOpacityGraph)
        case 1:
            self.nameLabel.text = destinationViewController.viewModel.city.name
            self.nameLabel.frame.origin.x = self.horizontalOffset
            self.nameLabel.layer.opacity = 1

            self.newNameLabel.text = nil
            self.newNameLabel.frame.origin.x = self.view.frame.width
            self.newNameLabel.layer.opacity = 0
        default:
            break
        }
        
    }

    func em_pageViewController(_ pageViewController: EMPageViewController,
                               didFinishScrollingFrom startingViewController: UIViewController?,
                               destinationViewController: UIViewController,
                               transitionSuccessful: Bool) {
        guard transitionSuccessful,
              let controller = destinationViewController as? CityViewController,
              let index = self.viewModel.firstIndexInCityList(of: controller.viewModel.city) else { return }
        self.updatePageControl(index: index)
    }
}
    
//// MARK: - Cities List View Controller Delegate
//
//extension CitiesPageViewController: CitiesListViewControllerDelegate {
//
//    func citiesListViewController(didSelectRowAt indexPath: IndexPath) {
//        self.backToPageViewController(withIndex: indexPath.row)
//    }
//
//    func citiesListViewController(shouldRemoveCityAt index: Int) {
//        CitiesCoreDataStack.shared.deleteCity(at: index)
//    }
//
//    func citiesListViewController(shouldMoveCityAt sourceIndex: Int, to destinationIndex: Int) {
//        CitiesCoreDataStack.shared.moveCity(at: sourceIndex, to: destinationIndex)
//    }
//
//    func citiesListViewControllerWillDisappear() {
//        self.checkDeletedViewControllers()
//    }
//}

// MARK: - City View Controller Delegate

//extension CitiesPageViewController: CityViewControllerDelegate {
//
//    func cityViewController(didUpdateCurrentWeatherFor city: City) {
//
//        CitiesCoreDataStack.shared.saveContext()
//
//        guard let controller = self.selectedViewController as? CityViewController else { return }
//        let isDayTime = controller.viewModel.city.currentWeather?.isDayTime ?? true
//        self.changeGradientColor(isDayTime: isDayTime)
//    }
//
//    func cityViewController(didUpdateHourlyForecastFor city: City) {
//        CitiesCoreDataStack.shared.saveContext()
//    }
//
//    func cityViewController(didUpdateDailyForecastFor city: City) {
//        CitiesCoreDataStack.shared.saveContext()
//    }
//
//    func cityViewController(scrollViewDidScroll scrollView: UIScrollView) {
//        let fontSize = self.nameLabelFontSize - scrollView.contentOffset.y
//        if fontSize < self.nameLabelFontSize * 2 &&
//            fontSize > self.nameLabelMinimumFontSize {
//            self.nameLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
//            self.newNameLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
//        }
//    }
//}
