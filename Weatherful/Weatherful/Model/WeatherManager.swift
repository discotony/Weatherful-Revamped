//
//  WeatherManager.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import Foundation
import CoreLocation

// https://api.openweathermap.org/data/2.5/&units=imperial&appid={API key}&weather?q={city name}
// https://api.openweathermap.org/data/2.5/weather?appid=69909afa26903a28166857e723462128&units=imperial&q=Berlin

private var APIKey = "69909afa26903a28166857e723462128"

enum tempUnits {
    case metric
    case imperial
}

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) //FOLLOWUP
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let urlStringTemplate = "https://api.openweathermap.org/data/2.5/weather?appid=\(APIKey)&units=imperial"
//    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=69909afa26903a28166857e723462128&units=imperial&q="
    
    var delegate: WeatherManagerDelegate?
    
    // MARK: - Fetch Weather by City Name
    func fetchWeather(from cityName: String) {
        let urlString = "\(urlStringTemplate)&q=\(cityName)"
//        let urlString = weatherUrl + cityName
        print(urlString)
        performURLRequest(with: urlString)
    }
    
    // MARK: - by Geo-coordinates
    // Using Geo-coordinates: https://api.openweathermap.org/data/2.5/weather?appid={API key}&lat={lat}&lon={lon}
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString =  "\(urlStringTemplate)&lat=\(latitude)&lon=\(longitude)"
        performURLRequest(with: urlString)
    }
    
//    func fetchWeather(by zipCode) {
//
//    }
    
    private func performURLRequest(with urlString: String) {
        // 1. Create a URL
        if let url = URL(string: urlString) {
            
            // 2. Create a URL Session
            let session = URLSession(configuration: .default)
                        
            // 3. Create a task
            // let task = session.dataTask(with: <#T##URLRequest#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)
            let task = session.dataTask(with: url) { data, response, error in
                
                // error handling
                if error != nil {
                    delegate?.didFailWithError(error: error!) //FOLLOWUP
                    return
                }
                
                // if no error
                if let safeData = data {
                    if let weather = parseJOSN(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // 4. Start the task
            task.resume() //FOLLOWUP
        }
        
        func parseJOSN(_ weatherData: Data) -> WeatherModel? {
            let decoder = JSONDecoder()
            // decoder.decode(T##type: Decodable.Protocol##Decodable.Protocol, from: <#T##Data#>)
            // "Call can throw, but it is not marked with 'try' and the error is not handled" //FOLLOWUP
            do {
                let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
                let cityName = decodedData.name
                let conditionId = decodedData.weather[0].id
                let condition = decodedData.weather[0].main
                let conditionDescription = decodedData.weather[0].description.capitalizeFirstLetters
                let tempCurrent = decodedData.main.temp
                let tempFeelsLike = decodedData.main.feels_like
                let tempMin = decodedData.main.temp_min
                let tempMax = decodedData.main.temp_max
                let wind = decodedData.wind.speed
                let humidity = decodedData.main.humidity
                
                print(cityName)
                print(conditionId)
                print(condition)
                print(conditionDescription)
                print(tempCurrent)
                print(wind)
                print(humidity)
                
                return WeatherModel(cityName: cityName,
                                    conditionId: conditionId,
                                    condition: condition,
                                    conditionDescription: conditionDescription,
                                    tempCurrent: tempCurrent,
                                    tempFeelsLike: tempFeelsLike,
                                    tempMin: tempMin,
                                    tempMax: tempMax,
                                    wind: wind,
                                    humidity: humidity)
                
            } catch { // if it does throw an error
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
    }
}

