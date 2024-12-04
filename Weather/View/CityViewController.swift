//
//  CityViewController.swift
//  Weather
//
//  Created by Вадим on 04.12.2024.
//

import UIKit

class CityViewController: UIViewController {

    // MARK: - Properties
    
    let viewModel: CityViewModel

    var weatherInfoView: WeatherInfoView
    let cityRefreshControl = UIRefreshControl()

    let frameRectangle: CGRect

    private var isConfigured = false

    weak var delegate: CityViewControllerDelegate?


    // MARK: - Lifecycle

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        print("viewSafeAreaInsetsDidChange")
        if !isConfigured {
            self.configure()
        }
    }

    // MARK: - Initializers

    init(_ city: City, frame: CGRect) {
        self.viewModel = CityViewModel(city: city)
        self.weatherInfoView = WeatherInfoView(for: city)
        self.frameRectangle = frame

        super.init(nibName: nil, bundle: nil)

        weatherInfoView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - IBActions

    @IBAction func refreshWeatherInfo() {
        self.weatherInfoView.refreshWeather()
    }

    // MARK: - Flow funcs

    private func configure() {

        self.cityRefreshControl.addTarget(self, action: #selector(refreshWeatherInfo), for: .valueChanged)
        self.cityRefreshControl.tintColor = .white

        self.weatherInfoView.frame.size.width = self.view.frame.width
        self.weatherInfoView.configure()

        let cityScrollView = UIScrollView()
        cityScrollView.delegate = self
        cityScrollView.frame = CGRect(x: self.frameRectangle.origin.x,
                                      y: self.frameRectangle.origin.y + self.view.safeAreaInsets.top,
                                      width: self.frameRectangle.width,
                                      height: self.frameRectangle.height - self.view.safeAreaInsets.top)
        cityScrollView.contentSize = self.weatherInfoView.frame.size
        cityScrollView.showsVerticalScrollIndicator = false

        cityScrollView.addSubview(self.weatherInfoView)
        cityScrollView.refreshControl = cityRefreshControl
        self.view.addSubview(cityScrollView)

        self.isConfigured = true
    }

    func addFade(to scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y

        let alpha:CGFloat = (scrollViewHeight >= scrollContentSizeHeight || scrollOffset <= 0) ? 1 : 0

        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 0.1)
        gradient.frame = CGRect(x: 0, y: 0,
                                width: scrollView.frame.size.width,
                                height: scrollView.frame.size.height)
        gradient.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: alpha).cgColor,
                           UIColor.black.cgColor]

        let mask = CALayer()
        mask.frame = scrollView.bounds
        mask.addSublayer(gradient)

        scrollView.layer.mask = mask
    }
}

// MARK: - Scroll View Delegate

extension CityViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 1) {
            self.addFade(to: scrollView)
        }
        self.delegate?.cityViewController(scrollViewDidScroll: scrollView)
    }

}

// MARK: - Weather Info View Delegate

extension CityViewController: WeatherInfoViewDelegate {

    func weatherInfoView(didUpdateWeatherInfoFor city: City) {
        self.cityRefreshControl.endRefreshing()
    }

    func weatherInfoView(didUpdateCurrentWeatherFor city: City) {
        self.delegate?.cityViewController(didUpdateCurrentWeatherFor: self.viewModel.city)
    }

    func weatherInfoView(didUpdateHourlyForecastFor city: City) {
        self.delegate?.cityViewController(didUpdateHourlyForecastFor: self.viewModel.city)
    }

    func weatherInfoView(didUpdateDailyForecastFor city: City) {
        self.delegate?.cityViewController(didUpdateDailyForecastFor: self.viewModel.city)
    }

}
