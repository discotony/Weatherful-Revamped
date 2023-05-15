//
//  WeatherManager.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import Foundation
import CoreLocation

private var APIKey = "69909afa26903a28166857e723462128"

enum tempUnits { // FOLLOWUP
    case metric
    case imperial
}

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) //FOLLOWUP
    func didUpdateForecast(_ weatherManager: WeatherManager, forecast: [ForecastModel])
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=\(APIKey)&units=imperial"
    let forecastUrl = "https://api.openweathermap.org/data/2.5/forecast?appid=\(APIKey)&units=imperial"
    
    var delegate: WeatherManagerDelegate?
    
    // MARK: - Fetch Weather by City Name
    func fetchWeather(from cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performURLRequest(with: urlString)
    }
    
    // MARK: - Fetch Weather by Geo-coordinates
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performURLRequest(with: urlString)
    }
    
    //    func fetchWeather(by zipCode) { // FOLLOWUP
    //
    //    }
    
    // MARK: - Fetch Forecast
    func fetchForecast(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(forecastUrl)&lat=\(latitude)&lon=\(longitude)"
        performURLRequest(with: urlString, isForecast: true)
    }
    
    private func performURLRequest(with urlString: String, isForecast: Bool = false) {
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
                    if isForecast {
                        if let forecast = parseForecastJSON(safeData) {
                            delegate?.didUpdateForecast(self, forecast: forecast)
                        }
                    } else if let weather = parseWeatherJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // 4. Start the task
            task.resume() //FOLLOWUP
        }
        
        func parseWeatherJSON(_ weatherData: Data) -> WeatherModel? {
            let decoder = JSONDecoder()
            // decoder.decode(T##type: Decodable.Protocol##Decodable.Protocol, from: <#T##Data#>)
            // "Call can throw, but it is not marked with 'try' and the error is not handled" //FOLLOWUP
            do {
                let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
                let cityName = decodedData.name
                let coordinates = decodedData.coord
                let conditionId = decodedData.weather[0].id
                let condition = decodedData.weather[0].main
                let conditionDescription = decodedData.weather[0].description.capitalizeFirstLetters
                let tempCurrent = decodedData.main.temp
                let tempMin = decodedData.main.temp_min
                let tempMax = decodedData.main.temp_max
                let wind = decodedData.wind.speed
                let humidity = decodedData.main.humidity
                
                return WeatherModel(cityName: cityName,
                                    coordinates: coordinates,
                                    conditionId: conditionId,
                                    condition: condition,
                                    conditionDescription: conditionDescription,
                                    tempCurrent: tempCurrent,
                                    tempMin: tempMin,
                                    tempMax: tempMax,
                                    wind: wind,
                                    humidity: humidity)
                
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
        
        func parseForecastJSON(_ forecastData: Data) -> [ForecastModel]? {
            let decoder = JSONDecoder()
            
            do {
                let decodedData = try decoder.decode(ForecastData.self, from: forecastData)
                var forecastArray = [ForecastModel]()
                
                for index in 0..<decodedData.list.count {
                    let cityName = decodedData.city.name
                    let coordinates = decodedData.city.coord // FOLLOW-UP: remove if unused
                    let list = decodedData.list[index]
                    let weatherDate = WeatherDate(timestamp: list.dt)
                    let weather = list.weather[0]
                    let conditionId = weather.id
                    let conditionDescription = weather.description.capitalizeFirstLetters
                    let temp = list.main.temp
                    
                    let forecast = ForecastModel(cityName: cityName,
                                                 coordinates: coordinates,
                                                 weatherDate: weatherDate,
                                                 conditionId: conditionId,
                                                 conditionDescription: conditionDescription,
                                                 temp: temp)
                    
                    forecastArray.append(forecast)
                }
                return forecastArray
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
    }
}
