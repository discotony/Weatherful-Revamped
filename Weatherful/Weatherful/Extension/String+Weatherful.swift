//
//  String+Weatherful.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

extension String {
    // FOLLOW-UP String vs. StringProtocol
    var capitalizeFirstWord: String { prefix(1).uppercased() + dropFirst() }
    var capitalizeFirstLetters: String { prefix(1).capitalized + dropFirst() }
    
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
    func replace(_ with: String, at index: Int) -> String {
        var modifiedString = String()
        for (i, char) in self.enumerated() {
            modifiedString += String((i == index) ? with : String(char))
        }
        return modifiedString
    }
}
