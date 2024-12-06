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
                
        var contentWidth = self.innerOffset
        
        var previousView: OneHourView?
        
        for var view in self.hourlyForecastViews {
            
            contentWidth += oneHourViewSize.width + self.innerOffset
                        
            view = OneHourView.instanceFromNib()
            view.configure()
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
            
            var leadingAnchor: NSLayoutConstraint
            
            if let previousView = previousView {
                leadingAnchor = view.leadingAnchor.constraint(equalTo: previousView.trailingAnchor)
            } else {
                leadingAnchor = view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            }
            leadingAnchor.constant = self.innerOffset
            
            NSLayoutConstraint.activate([
                leadingAnchor,
                view.topAnchor.constraint(equalTo: self.topAnchor),
                view.widthAnchor.constraint(equalToConstant: oneHourViewSize.width),
                view.heightAnchor.constraint(equalToConstant: oneHourViewSize.height),
            ])
            
            previousView = view
        }
        
        self.contentSize.width = contentWidth
    }
    
    func startSkeleton() {
        let _ = self.hourlyForecastViews.map({ $0.startSkeleton() })
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
    
}
