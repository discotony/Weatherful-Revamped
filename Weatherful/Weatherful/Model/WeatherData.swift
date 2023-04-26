//
//  WeatherData.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import Foundation

// https://api.openweathermap.org/data/2.5/weather?appid=69909afa26903a28166857e723462128&units=imperial&q=Berlin

struct WeatherData: Decodable {
    var name: String
    var coord: Coord
    var weather: [Weather]
    var main: Main
    var wind: Wind
}

struct Coord: Decodable {
    var lat: Double
    var lon: Double
}

struct Weather: Decodable {
    var id: Int
    var main: String
    var description: String
}

struct Main: Decodable {
    var temp: Double
    var feels_like: Double
    var temp_min: Double
    var temp_max: Double
    var humidity: Int
}

struct Wind: Decodable {
    var speed: Double
}
