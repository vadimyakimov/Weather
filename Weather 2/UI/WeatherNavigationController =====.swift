//
//  WeatherNavigationController.swift
//  Weather 2
//
//  Created by Вадим on 14.02.2022.
//

import UIKit

class WeatherNavigationController: UINavigationController {
    
    
    var statusBarFrame = CGRect()
    var navigationBarFrame = CGRect()
    var backgroundColor: UIColor?
    private var isHidden: Bool = false
    private var isOpaque: Bool?
    lazy private var hidingLayer = CALayer()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.statusBarFrame = UIApplication.shared.statusBarFrame
        self.navigationBarFrame = super.navigationBar.frame
        
        self.setSystemBackgroundColor()
    }
    
    private func setSystemBackgroundColor() {
        if #available(iOS 13.0, *) {
            self.backgroundColor = .systemBackground
        } else {
            self.backgroundColor = .systemGray
        }
    }
    
    func setBackgroungColor(to viewController: UIViewController) {
        guard let backgroundColor = backgroundColor else { return }

        let backgroundView = UIView(frame: CGRect(x: 0,
                                                  y: -self.view.frame.height,
                                                  width: self.view.frame.width,
                                                  height: self.view.frame.height))
        backgroundView.backgroundColor = backgroundColor
        viewController.view.addSubview(backgroundView)
    }
    
    func hideNavigationController(isOpaque: Bool = true) {
        guard !self.isHidden else { return }
        
        var height = self.navigationBarFrame.height
        
        if isOpaque {
            self.isOpaque = true
            self.configureHidingLayer()
            self.view.layer.addSublayer(self.hidingLayer)
        } else {
            self.isOpaque = false
            height += self.statusBarFrame.height
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y -= height
            self.view.frame.size.height += height
        }
        
        self.isHidden = true
    }
    
    func showNavigationController() {
        guard self.isHidden else { return }

        var height = self.navigationBarFrame.height
        
        if self.isOpaque == true {
            self.hidingLayer.removeFromSuperlayer()
        } else {
            height += self.statusBarFrame.height
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y += height
            self.view.frame.size.height -= height
        }
        
        self.isOpaque = nil
        self.isHidden = false
    }
    
    private func configureHidingLayer() {
        self.hidingLayer.frame = CGRect(x: 0, y: 0,
                                        width: self.navigationBarFrame.width,
                                        height: self.statusBarFrame.height + self.navigationBarFrame.height)
        if let backgroundColor = self.backgroundColor {
            self.hidingLayer.backgroundColor = backgroundColor.cgColor
        } else {
            self.hidingLayer.backgroundColor = UIColor.white.cgColor
        }
    }
    
}

extension WeatherNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        self.setBackgroungColor(to: viewController)
    }
}
