//
//  ForecastModel.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/10/23.
//

import Foundation

// https://api.openweathermap.org/data/2.5/forecast?appid=69909afa26903a28166857e723462128&lat=38.53&lon=-121.79

struct ForecastModel {
    var cityName: String
    var coordinates: Coord
    var timeString: String
    var dateString: String


                        
    var conditionId: Int
    var conditionDescription: String
    
    var staticConditionName: String {
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
    
    var temp: Double
    
    var tempString: String {
        return String(Int(temp)) + "°F"
    }
    
    var wind: Double
    var humidity: Int
    
    var windString: String {
        return String(format: "%.1f", wind) + " mph"
    }
    
    var humidityString: String {
        return "\(humidity) %"
    }
}
