//
//  DailyForecastView.swift
//  Weather
//
//  Created by Вадим on 06.12.2024.
//

import UIKit

class DailyForecastView: UIView {
    
    // MARK: - Properties
    
    private let dailyViewCornerRadius: CGFloat = 20
    private let verticalSpacing: CGFloat
    
    private var dailyForecastViews: [OneDayView] = (0..<5).map { _ in
        let view = OneDayView.instanceFronNib()
        view.configure()
        return view
    }
    
    // MARK: - Initializers
    
    init(verticalSpacing: CGFloat) {
        self.verticalSpacing = verticalSpacing
                
        super.init(frame: .zero)
        
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Funcs
    
    private func configure() {
                
        self.clipsToBounds = true
        self.layer.cornerRadius = self.dailyViewCornerRadius
        
        for (index, view) in self.dailyForecastViews.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
            
            let topAnchor = (index == 0)
                ? view.topAnchor.constraint(equalTo: self.topAnchor)
                : view.topAnchor.constraint(equalTo: self.dailyForecastViews[index - 1].bottomAnchor)
            
            NSLayoutConstraint.activate([
                topAnchor,
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.heightAnchor.constraint(equalToConstant: view.frame.height),
            ])
        }
        
        self.dailyForecastViews.last?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    func updateForecast(_ dailyForecast: [DailyForecastProviding]?, isImperial: Bool) {
                
        guard let data = dailyForecast,
              data.count == self.dailyForecastViews.count else { return }
        
        for (index, view) in self.dailyForecastViews.enumerated() {
            
            let dayTemperature = Temperature(temperatureCelsius: data[index].dayWeather.temperatureCelsius,
                                             temperatureFahrenheit: data[index].dayWeather.temperatureFahrenheit,
                                             isImperial: isImperial)
            let nightTemperature = Temperature(temperatureCelsius: data[index].nightWeather.temperatureCelsius,
                                             temperatureFahrenheit: data[index].nightWeather.temperatureFahrenheit,
                                               isImperial: isImperial)
            
            view.configure(date: data[index].forecastDate,
                           dayTemperature: dayTemperature,
                           nightTemperature: nightTemperature,
                           dayIcon: Int(data[index].dayWeather.weatherIcon),
                           nightIcon: Int(data[index].nightWeather.weatherIcon))
        }
    }
    
    func setMetricUnit(_ isImperial: Bool) {
        self.dailyForecastViews.forEach {
            $0.dayTemperature?.isImperial = isImperial
            $0.nightTemperature?.isImperial = isImperial
        }
    }
    
    func startSkeleton() {
        self.dailyForecastViews.forEach({ $0.startSkeleton() })
    }
    
    func stopSkeleton() {
        self.dailyForecastViews.forEach({ $0.stopSkeleton() })
    }
    
}
