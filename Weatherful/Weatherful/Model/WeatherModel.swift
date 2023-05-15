//
//  WeatherModel.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import Foundation
import CoreLocation

// https://api.openweathermap.org/data/2.5/weather?appid=69909afa26903a28166857e723462128&units=imperial&q=Berlin

struct WeatherModel {
    var cityName: String
    var coordinates: Coord
    var conditionId: Int
    var condition: String
    var conditionDescription: String
    
    var conditionName: String {
        switch conditionId {
        // thunderstorm
        case 200...202:
            return "thunder_rain"
        case 203...210:
            return "thunder_light"
        case 211...221:
            return "thunder_heavy"
        case 222...232:
            return "thunder_drizzle"
            
        // drizzle
        case 300...321:
            return "drizzle"
        // rain
        case 500...531:
            return "rain"
            
        // snow
        case 601:
            return "cloud_snow"
        case 602:
            return "snow"
        case 603...622:
            return "cloud_snow"
            
        // Atmosphere
        case 701...762:
            return "fog"
        case 771:
            return "squall"
        case 781:
            return "tornado"
            
        // clear
        case 800:
            return "clear"
            
        // clouds
        case 801:
            return "cloud_light"
        case 802:
            return "cloud"
        case 803...804:
            return "cloud_heavy"
        default:
            return ""
        }
    }
    
    var animatedConditionName: String {
        switch conditionId {
        // thunderstorm
        case 200...202:
            return "thunderstorms-rain"
        case 210...221:
            return "thunderstorms"
        case 230...232:
            return "thunderstorms-rain"
            
        // drizzle
        case 300...321:
            return "drizzle"
        // rain
        case 500...531:
            return "rain"
            
        // snow
        case 600...602:
            return "snow"
        case 611-616:
            return "sleet"
        case 620...622:
            return "snow"

        // Atmosphere
        case 701:
            return "mist"
        case 711:
            return "smoke"
        case 721:
            return "haze"
        case 731:
            return "dust-wind"
        case 741:
            return "fog"
        case 751...762:
            return ""
        case 771:
            return "wind"
        case 781:
            return "tornado"
            
        // clear
        case 800:
            return "clear-day"
            
        // clouds
        case 801:
            return "partly-cloudy-day"
        case 802:
            return "cloudy"
        case 803...804:
            return "overcast"
        default:
            return "not-available-day"
        }
    }
    
    var tempCurrent: Double
    var tempMin: Double
    var tempMax: Double
    var wind: Double
    var humidity: Int
    
    var tempCurrentString: String {
        return String(Int(tempCurrent)) + "°F"
    }
    
    var tempMinString: String {
        return String(format: "%.1f", tempMax) + "°F"
    }
    var tempMaxString: String {
        return String(format: "%.1f", tempMax) + "°F"
    }
       
    var windString: String {
        return String(format: "%.1f", wind) + " mph"
    }
    
    var humidityString: String {
        return "\(humidity) %"
    }
}
