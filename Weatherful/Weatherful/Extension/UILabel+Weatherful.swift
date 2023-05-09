//
//  UILabel+Weatherful.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import UIKit

extension UILabel {
    
    func configure(text: String? = nil, font: UIFont, color: UIColor = .weatherfulWhite, isCenterAligned: Bool = false) {
        if let text = text { self.text = text }
        self.font = font
        self.textColor = color
        if isCenterAligned { self.textAlignment = .center }
    }

    func applyLabelShadow(isTextDark: Bool) {
        self.layer.shadowColor = isTextDark ? UIColor.weatherfulWhite.cgColor : UIColor.weatherfulBlack.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 6.0
        self.layer.masksToBounds = false
    }
}
