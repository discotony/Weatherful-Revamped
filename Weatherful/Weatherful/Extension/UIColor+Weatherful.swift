//
//  UIColor+Weatherful.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import UIKit

extension UIColor {
    
    // MARK: - Custom Colors
    static let weatherfulLightGrey: UIColor = {
        return UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    }()
    
    static let weatherfulDarkGrey: UIColor = {
        return UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
    }()
    
    static let weatherfulWhite: UIColor = {
        return .white
    }()
    
    static let weatherfulBlack: UIColor = {
        return UIColor(red: 32.0/255.0, green: 33.0/255.0, blue: 36.0/255.0, alpha: 1.0)
    }()
    
    static let weatherfulPlaceholderGrey: UIColor = {
        return UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    }()
    
    static let weatherWarningRed: UIColor = {
        return UIColor(red: 220.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    }()
}
