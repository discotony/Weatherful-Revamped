//
//  WeatherModel.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import Foundation

// https://api.openweathermap.org/data/2.5/weather?appid=69909afa26903a28166857e723462128&units=imperial&q=Berlin

struct WeatherModel {
    var cityName: String
    
    var conditionId: Int
    var condition: String
    var conditionDescription: String
    
    var conditionName: String {
        switch conditionId {
        // thunderstorm
        case 200...232:
            return "cloud_bolt"
        // drizzle
        case 300...321:
            return "cloud_drizzle"
        // rain
        case 500...531:
            return "cloud_rain"
        // snow
        case 600...622:
            return "cloud_snow"
        // Atmosphere
        case 701...781:
            return "cloud_fog"
        // clear
        case 800:
            return "sun_max"
        // clouds
        case 801...804:
            return "cloud_bolt"
        default:
            return "cloud"
        }
    }
    
    var tempCurrent: Double
    var tempFeelsLike: Double
    var tempMin: Double
    var tempMax: Double
    
    var tempCurrentString: String {
        return String(format: "%.1f", tempCurrent)
    }
    
    var tempFeelsLikeString: String {
        return String(format: "%.1f", tempFeelsLike)
    }
    
    var tempMinString: String {
        return String(format: "%.1f", tempMax)
    }
    var tempMaxString: String {
        return String(format: "%.1f", tempMax)
    }
       
    var wind: Double
    var humidity: Int
}
