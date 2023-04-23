//
//  Fonts+Weatherful.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import UIKit

struct WeatherfulFonts {
    
    // MARK: - List of Fonts
    // SFProDisplay-Black
    // SFProDisplay-Bold
    // SFProDisplay-Heavy
    // SFProDisplay-Light
    // SFProDisplay-Medium
    // SFProDisplay-Regular
    // SFProDisplay-Semibold
    // SFProDisplay-Thin
    // SFProDisplay-Ultralight
    // SFProText-Black
    // SFProText-Bold
    // SFProText-Heavy
    // SFProText-Light
    // SFProText-Medium
    // SFProText-Regular
    // SFProText-Semibold
    // SFProText-Thin
    // SFProText-Ultralight
    
    // MARK: - <#Section Heading#>
    static let titleXL = UIFont(name: "SFProText-Bold", size: 84.0)
    
    // MARK: - <#Section Heading#>
    static let titmeLarge = UIFont(name: "SFProText-Bold", size: 20.0)
    
    // MARK: - <#Section Heading#>
    static let captionLarge = UIFont(name: "SFProText-Regular", size: 20.0)
    
    // MARK: - searchTextField
    static let captionMedium = UIFont(name: "SFProText-Regular", size: 16.0)
    
    // MARK: - <#Section Heading#>
    static let captionSmall = UIFont(name: "SFProText-Medium", size: 14.0)
}

func listFontNames() {
    for family: String in UIFont.familyNames
    {
        print("\(family)")
        for names: String in UIFont.fontNames(forFamilyName: family)
        {
            print("== \(names)")
        }
    }
}
