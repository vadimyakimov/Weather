//
//  HourlyForecastView.swift
//  Weather
//
//  Created by Вадим on 06.12.2024.
//

import UIKit

class HourlyForecastView: UIScrollView {
    
    let verticalSpacing: CGFloat
    let innerOffset: CGFloat
    
    private var hourlyForecastViews = [OneHourView](repeating: OneHourView(), count: 12)

    init(verticalSpacing: CGFloat, innerOffset: CGFloat) {
        self.verticalSpacing = verticalSpacing
        self.innerOffset = innerOffset
        super.init(frame: .zero)
        
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure() {
        
        let oneHourViewSize = OneHourView.instanceFromNib().frame.size
                
        self.showsHorizontalScrollIndicator = false
        
        for index in 0..<self.hourlyForecastViews.count {
            let view = OneHourView.instanceFromNib()
            view.configure()
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
            
            let leadingAnchor = (index == 0)
                ? view.leadingAnchor.constraint(equalTo: self.contentLayoutGuide.leadingAnchor)
                : view.leadingAnchor.constraint(equalTo: self.hourlyForecastViews[index - 1].trailingAnchor)
            leadingAnchor.constant = self.innerOffset
            
            NSLayoutConstraint.activate([
                leadingAnchor,
                view.topAnchor.constraint(equalTo: self.contentLayoutGuide.topAnchor),
                view.widthAnchor.constraint(equalToConstant: oneHourViewSize.width),
                view.heightAnchor.constraint(equalToConstant: oneHourViewSize.height),
                
                view.heightAnchor.constraint(equalTo: self.frameLayoutGuide.heightAnchor),
            ])
            
            self.hourlyForecastViews[index] = view
        }
        
        self.hourlyForecastViews.last?.trailingAnchor.constraint(equalTo: self.contentLayoutGuide.trailingAnchor,
                                                                 constant: -self.innerOffset).isActive = true
    }
    
    func updateForecast(_ hourlyForecast: [HourlyForecast]?) {
                
        guard let data = hourlyForecast,
              data.count == self.hourlyForecastViews.count else { return }
        
        for (index, view) in self.hourlyForecastViews.enumerated() {
            view.configure(time: data[index].forecastTime,
                           temperature: Int(data[index].temperatureCelsius),
                           weatherText: data[index].weatherText,
                           weatherIcon: Int(data[index].weatherIcon))
        }
    }
    
    func startSkeleton() {
        let _ = self.hourlyForecastViews.map({ $0.startSkeleton() })
    }
}
