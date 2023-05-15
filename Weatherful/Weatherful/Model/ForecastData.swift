//
//  ForecastData.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/10/23.
//

import Foundation

struct ForecastData: Decodable {
    var city: City
    var list: [List]
}

struct City: Decodable {
    var name: String
    var coord: Coord
}

struct List: Decodable {
    var dt: Double
    var main: Main
    var weather: [Weather]
}
