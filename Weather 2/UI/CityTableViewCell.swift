//
//  CityTableViewCell.swift
//  Weather 2
//
//  Created by Вадим on 17.01.2022.
//

import UIKit

class CityTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var label = UILabel()
    var locationImage = UIImageView()
    
    private let locationImageSide: CGFloat = 15
    private let labelHeight: CGFloat = 40
    private let sideOffset: CGFloat = 10
    
    // MARK: - Flow funcs
    
    func configure(withSize size: CGSize, text: String, isLocation: Bool = false) {
        self.label.frame = CGRect(x: self.sideOffset,
                                  y: (size.height - self.labelHeight) / 2,
                                  width: size.width - (self.sideOffset * 2),
                                  height: self.labelHeight)
        self.label.text = text
        self.contentView.addSubview(label)
        if isLocation {
            self.locationImage.image = UIImage(named: "location")
            self.locationImage.frame = CGRect(x: size.width - (self.locationImageSide * 2),
                                              y: (size.height - self.locationImageSide) / 2,
                                              width: self.locationImageSide,
                                              height: self.locationImageSide)
            self.contentView.addSubview(locationImage)
        }
    }

}
