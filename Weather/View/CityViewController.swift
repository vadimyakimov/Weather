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

    weak var delegate: CityViewControllerDelegate?


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    // MARK: - Initializers

    init(viewModel: CityViewModel) {
        self.viewModel = viewModel
        self.weatherInfoView = WeatherInfoView(for: self.viewModel.city)

        super.init(nibName: nil, bundle: nil)

        weatherInfoView.viewModel.delegate = self
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
        
        self.cityRefreshControl.addTarget(self, action: #selector(self.refreshWeatherInfo), for: .valueChanged)
        self.cityRefreshControl.tintColor = .white

        let cityScrollView = UIScrollView()
        let weatherView = self.weatherInfoView
        
        cityScrollView.delegate = self
        cityScrollView.refreshControl = cityRefreshControl
        cityScrollView.showsVerticalScrollIndicator = false
        
        cityScrollView.translatesAutoresizingMaskIntoConstraints = false
        weatherView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(cityScrollView)
        cityScrollView.addSubview(weatherView)
        
        NSLayoutConstraint.activate([
            cityScrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
            cityScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            cityScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            cityScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            weatherView.topAnchor.constraint(equalTo: cityScrollView.contentLayoutGuide.topAnchor),
            weatherView.leadingAnchor.constraint(equalTo: cityScrollView.contentLayoutGuide.leadingAnchor),
            weatherView.trailingAnchor.constraint(equalTo: cityScrollView.contentLayoutGuide.trailingAnchor),
            weatherView.bottomAnchor.constraint(equalTo: cityScrollView.contentLayoutGuide.bottomAnchor),
            
            weatherView.widthAnchor.constraint(equalTo: cityScrollView.frameLayoutGuide.widthAnchor),
        ])
    }

    func addFade(to scrollView: UIScrollView) {
        
        var alpha = scrollView.contentOffset.y
        if alpha < 15 {
            alpha = 1 - (alpha / 15)
        } else {
            alpha = 0
        }
        
        let gradient = CAGradientLayer()
        gradient.frame = scrollView.bounds
        gradient.locations = [0.0, 0.1]
        gradient.colors = [UIColor(white: 0, alpha: alpha).cgColor, UIColor.black.cgColor]
        
        scrollView.layer.mask = gradient        
    }
}

// MARK: - Scroll View Delegate

extension CityViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.addFade(to: scrollView)
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
