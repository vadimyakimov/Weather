//
//  CityViewController+extensions.swift
//  Weather 2
//
//  Created by Вадим on 21.01.2022.
//

import Foundation
import UIKit

extension CityViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.setScrollViewFade()
        let fontSize = self.nameLabelFontSize - scrollView.contentOffset.y
        if fontSize < self.nameLabelFontSize * 2 &&
           fontSize > self.nameLabelMinimumFontSize {
            self.nameLabel.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
    
}
