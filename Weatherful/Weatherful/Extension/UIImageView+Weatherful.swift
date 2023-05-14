//
//  UIImageView+Weatherful.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/13/23.
//

import UIKit

extension UIImageView {
    func updateBackground(){
        switch Date().hour {
        case 00...04:
            self.image = UIImage(named: "00-04")
        case 5:
            self.image = UIImage(named: "05")
        case 6...7:
            self.image = UIImage(named: "06-07")
        case 8...9:
            self.image = UIImage(named: "08-09")
        case 10...11:
            self.image = UIImage(named: "10-11")
        case 12...15:
            self.image = UIImage(named: "12-15")
        case 16...18:
            self.image = UIImage(named: "16-18")
        case 19:
            self.image = UIImage(named: "19")
        case 20:
            self.image = UIImage(named: "20")
        case 21:
            self.image = UIImage(named: "21")
        case 22...24: // FOLLOWUP
            self.image = UIImage(named: "22-23")
        default:
            break
        }
    }
}
