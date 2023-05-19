//
//  PlaceModel.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/19/23.
//

import Foundation

struct Place {
    let name: String
    let id: String
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
    
    var formattedName: String {
        let splittedStringArray = name.components(separatedBy: ",")
        let lastIndex = splittedStringArray.count - 1
        if splittedStringArray[lastIndex] == " USA" {
            return splittedStringArray[0] + "," + splittedStringArray[lastIndex - 1]
        } else {
            return splittedStringArray[0] + "," + splittedStringArray[lastIndex]
        }
    }
}
