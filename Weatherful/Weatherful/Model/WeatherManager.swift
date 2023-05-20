//
//  WeatherManager.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import Foundation
import CoreLocation

private var APIKey = "69909afa26903a28166857e723462128"

enum RequestType {
    case weather
    case forecast
}

enum TempUnits { // FOLLOWUP
    case metric
    case imperial
}

enum WeatherError: Error {
    case failedToFetchWeather
    case failedToFetchForecast
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
    
    let dispatchGroup = DispatchGroup()
    
    func fetchWeatherData(with coordinates: CLLocationCoordinate2D) {
        let weatherString = "\(weatherUrl)&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)"
        let forecastString = "\(forecastUrl)&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)"

        performURLRequest(with: weatherString, requestType: .weather)
        performURLRequest(with: forecastString, requestType: .forecast)
    }
    
    private func performURLRequest(with urlString: String, requestType: RequestType) {
        dispatchGroup.enter()
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                guard let safeData = data, error == nil else {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if requestType == .weather {
                    if let weather = parseWeatherJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                } else if let forecast = parseForecastJSON(safeData) {
                    delegate?.didUpdateForecast(self, forecast: forecast)
                }
                dispatchGroup.leave()
            }
            task.resume()
        }
        
        func parseWeatherJSON(_ weatherData: Data) -> WeatherModel? {
            let decoder = JSONDecoder()
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
                return WeatherModel(city: cityName,
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
                    let list = decodedData.list[index]
                    let weatherDate = WeatherfulDate(timestamp: list.dt)
                    let weather = list.weather[0]
                    let conditionId = weather.id
                    let conditionDescription = weather.description.capitalizeFirstLetters
                    let temp = list.main.temp
                    
                    let forecast = ForecastModel(cityName: cityName,
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
