//
//  WeatherModel.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import Foundation
import CoreLocation

// https://api.openweathermap.org/data/2.5/weather?appid=69909afa26903a28166857e723462128&units=imperial&q=Berlin

enum WeatherfulUnit {
    case Metric
    case Imperial
}

struct WeatherModel {
    var city: String
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
    
    var tempCurrentImperial: Double
    var tempMinImperial: Double
    var tempMaxImperial: Double
    var windImperial: Double
    
    var tempCurrentMetric: Double {
        return Measurement(value: tempCurrentImperial, unit: UnitTemperature.fahrenheit).converted(to: UnitTemperature.celsius).value
    }
    var tempMinMetric: Double {
        return Measurement(value: tempMinImperial, unit: UnitTemperature.fahrenheit).converted(to: UnitTemperature.celsius).value
    }
    var tempMaxMetric: Double {
        return Measurement(value: tempMaxImperial, unit: UnitTemperature.fahrenheit).converted(to: UnitTemperature.celsius).value
    }
    var windMetric: Double {
        return Measurement(value: windImperial, unit: UnitSpeed.milesPerHour).converted(to: UnitSpeed.kilometersPerHour).value
    }
    
    
    var tempCurrentImperialString: String {
        return String(Int(tempCurrentImperial)) + "°F"
    }
    var tempMinImperialString: String {
        return String(format: "%.1f", tempMaxImperial) + "°F"
    }
    var tempMaxImperialString: String {
        return String(format: "%.1f", tempMaxImperial) + "°F"
    }
    var windImperialString: String {
        return String(format: "%.1f", windImperial) + " mph"
    }
    
    
    var tempCurrentMetricString: String {
        return String(Int(tempCurrentMetric)) + "°C"
    }
    var tempMinMetricString: String {
        return String(format: "%.1f", tempMinMetric) + "°C"
    }
    var tempMaxMetricString: String {
        return String(format: "%.1f", tempMaxMetric) + "°C"
    }
    var windMetricString: String {
        return String(format: "%.1f", windMetric) + " km/h"
    }
    
    var humidity: Int
    
    var humidityString: String {
        return "\(humidity) %"
    }
}
