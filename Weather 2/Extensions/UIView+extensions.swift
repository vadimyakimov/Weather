//
//  UIView+extensions.swift
//  Weather 2
//
//  Created by Вадим on 09.02.2022.
//

import Foundation
import UIKit

extension UIView {

  var safeTopAnchor: NSLayoutYAxisAnchor {
    if #available(iOS 11.0, *) {
      return safeAreaLayoutGuide.topAnchor
    }
      return topAnchor
  }

  var safeLeftAnchor: NSLayoutXAxisAnchor {
    if #available(iOS 11.0, *){
      return safeAreaLayoutGuide.leftAnchor
    }
    return leftAnchor
  }

  var safeRightAnchor: NSLayoutXAxisAnchor {
    if #available(iOS 11.0, *){
      return safeAreaLayoutGuide.rightAnchor
    }
    return rightAnchor
  }

  var safeBottomAnchor: NSLayoutYAxisAnchor {
    if #available(iOS 11.0, *) {
      return safeAreaLayoutGuide.bottomAnchor
    }
    return bottomAnchor
  }
}
