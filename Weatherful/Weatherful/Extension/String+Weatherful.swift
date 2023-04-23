//
//  String+Weatherful.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

extension StringProtocol {
    
    var capitalizeFirstWord: String { prefix(1).uppercased() + dropFirst() }
    var capitalizeFirstLetters: String { prefix(1).capitalized + dropFirst() }
}
