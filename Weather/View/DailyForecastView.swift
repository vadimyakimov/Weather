//
//  DailyForecastView.swift
//  Weather
//
//  Created by Вадим on 06.12.2024.
//

import UIKit

class DailyForecastView: UIView {
    
    let dailyViewCornerRadius: CGFloat = 20
    let verticalSpacing: CGFloat
    
    var dailyForecastViews = [OneDayView](repeating: OneDayView(), count: 5)

    init(verticalSpacing: CGFloat) {
        self.verticalSpacing = verticalSpacing
        super.init(frame: .zero)
        
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure() {
        
         self.clipsToBounds = true
         self.layer.cornerRadius = self.dailyViewCornerRadius
        
        let oneDayViewHeight = OneDayView.instanceFronNib().frame.height
                
        var previousView: OneDayView?
        
        for var view in self.dailyForecastViews {
            view = OneDayView.instanceFronNib()
            view.configure()
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
            
            let topAnchor: NSLayoutConstraint
            
            if let previousView = previousView {
                topAnchor = view.topAnchor.constraint(equalTo: previousView.bottomAnchor)
            } else {
                topAnchor = view.topAnchor.constraint(equalTo: self.topAnchor)
            }
            
            NSLayoutConstraint.activate([
                topAnchor,
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.heightAnchor.constraint(equalToConstant: oneDayViewHeight),
            ])
            
            previousView = view
            
        }
    }
        
    func updateForecast(_ dailyForecast: [DailyForecast]?) {
        
        guard let data = dailyForecast,
              data.count == self.dailyForecastViews.count else { return }
        
        for (index, view) in self.dailyForecastViews.enumerated() {
            view.configure(date: data[index].forecastDate,
                           dayTemperature: Int(data[index].dayWeather.temperatureCelsius),
                           nightTemperature: Int(data[index].nightWeather.temperatureCelsius),
                           dayIcon: Int(data[index].dayWeather.weatherIcon),
                           nightIcon: Int(data[index].nightWeather.weatherIcon))
        }
    }
    
    func startSkeleton() {
        let _ = self.dailyForecastViews.map({ $0.startSkeleton() })
    }

}
