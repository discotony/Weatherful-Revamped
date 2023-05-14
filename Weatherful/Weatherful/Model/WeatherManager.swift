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
    func didUpdateForecast(_ weatherManager: WeatherManager, forecast: [ForecastModel])
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=\(APIKey)&units=imperial"
    let forecastUrl = "https://api.openweathermap.org/data/2.5/forecast?appid=\(APIKey)&units=imperial"
    //    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=69909afa26903a28166857e723462128&units=imperial&q="
    
    var delegate: WeatherManagerDelegate?
    
    // MARK: - Fetch Weather by City Name
    func fetchWeather(from cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        //        let urlString = weatherUrl + cityName
        //        print(urlString)
        performURLRequest(with: urlString)
    }
    
    // MARK: - by Geo-coordinates
    // Using Geo-coordinates: https://api.openweathermap.org/data/2.5/weather?appid={API key}&lat={lat}&lon={lon}
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performURLRequest(with: urlString)
    }
    
    //    func fetchWeather(by zipCode) {
    //
    //    }
    
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
                let latitude = decodedData.coord.lat
                let longitude = decodedData.coord.lon
                let conditionId = decodedData.weather[0].id
                let condition = decodedData.weather[0].main
                let conditionDescription = decodedData.weather[0].description.capitalizeFirstLetters
                let tempCurrent = decodedData.main.temp
                let tempFeelsLike = decodedData.main.feels_like
                let tempMin = decodedData.main.temp_min
                let tempMax = decodedData.main.temp_max
                let wind = decodedData.wind.speed
                let humidity = decodedData.main.humidity
                
                //                print(cityName)
                //                print(conditionId)
                //                print(condition)
                //                print(conditionDescription)
                //                print(tempCurrent)
                //                print(wind)
                //                print(humidity)
                
                return WeatherModel(cityName: cityName,
                                    coordinates: Coord(lat: latitude, lon: longitude),
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
        
        func parseForecastJSON(_ forecastData: Data) -> [ForecastModel]? {
            let decoder = JSONDecoder()
            
            do {
                let decodedData = try decoder.decode(ForecastData.self, from: forecastData)
                var forecastArray = [ForecastModel]()
                
                let count = (decodedData.list.count)
                
                for index in 0..<count { // FOLLOWUP
                    let cityName = decodedData.city.name
                    let latitude = decodedData.city.coord.lat
                    let longitude = decodedData.city.coord.lon
                    let list = decodedData.list[index]
                    

                    // MARK: - Extract Date
                    let convertedTimeStamp = Date(timeIntervalSince1970: TimeInterval(list.dt)).toLocalTime().description
                    let dateString = formatDate(timestamp: convertedTimeStamp)
//                    print("dateString: " + dateString)
                    
                    // MARK: - Extract Day
                    let dayString = getDayOfWeekString(date: convertedTimeStamp)
//                    print("dayString: " + dayString)
                    
                    // MARK: - Extract Time
                    let formattedDateString = "\(dayString), \(dateString)"
//                    print("formattedDateString: " + formattedDateString)
//                    print("")
                    let timeString = formatTime(time: String(Array(convertedTimeStamp)[11...15]))
//                    print("timeString: " + timeString)
                    
                    let dateFullString = formatFullDate(timestamp: convertedTimeStamp)
                     
                    let weather = list.weather[0]
                    let conditionId = weather.id
                    let conditionDescription = list.weather[0].description.capitalizeFirstLetters
                    
                    let temp = list.main.temp
                    
                    let wind = list.wind.speed
                    let humidity = list.main.humidity
                    
                    
                    let forecast = ForecastModel(cityName: cityName,
                                                 coordinates: Coord(lat: latitude, lon: longitude),
                                                 timeString: timeString,
                                                 dateString: formattedDateString,
                                                 dateFullString: dateFullString,
                                                 conditionId: conditionId,
                                                 conditionDescription: conditionDescription,
                                                 temp: temp,
                                                 wind: wind,
                                                 humidity: humidity)
                    
                    forecastArray.append(forecast)
                }
                return forecastArray
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
        
        func formatDate(timestamp: String) -> String {
            
//            print("convertedTime: " + timestamp)
            
            var formattedString = String(Array(timestamp)[5...9]).replacingOccurrences(of: "-", with: "/")
            if formattedString[0] == "0" {
                formattedString = formattedString.replace("", at: 0)
                if formattedString[2] == "0" {
                    formattedString = formattedString.replace("", at: 2)
                }
            } else if formattedString[3] == "0" {
                formattedString = formattedString.replace("", at: 3)
            }
            return formattedString
        }
        
        func formatFullDate(timestamp: String) -> String {
            let month = String(Array(timestamp)[5...6])
            let date = String(Array(timestamp)[8...9])
            switch month {
            case "01":
                return "January" + " " + date
            case "02":
                return "February" + " " + date
            case "03":
                return "March" + " " + date
            case "04":
                return "April" + " " + date
            case "05":
                return "May" + " " + date
            case "06":
                return "June" + " " + date
            case "07":
                return "July" + " " + date
            case "08":
                return "August" + " " + date
            case "09":
                return "September" + " " + date
            case "10":
                return "October" + " " + date
            case "11":
                return "November" + " " + date
            case "12":
                return "December" + " " + date
            default:
                print("Error fetching date")
                return formatDate(timestamp: timestamp)
            }
        }

        func getDayOfWeekString(date: String) -> String {
            let today = String(Array(date)[0...9])
            let formatter  = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let todayDate = formatter.date(from: today)!
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components(.weekday, from: todayDate)
            let weekDay = myComponents.weekday
            switch weekDay {
            case 1:
                return "Sun"
            case 2:
                return "Mon"
            case 3:
                return "Tue"
            case 4:
                return "Wed"
            case 5:
                return "Thu"
            case 6:
                return "Fri"
            case 7:
                return "Sat"
            default:
                print("Error fetching days")
                return "Day"
            }
        }
        
        func formatTime(time: String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "H:mm"
            let date12 = dateFormatter.date(from: time)!
            
            dateFormatter.dateFormat = "h:mm a"
            let date22 = dateFormatter.string(from: date12).replacingOccurrences(of: ":00", with: "")
            return date22
            
        }
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
extension String {
    func replace(_ with: String, at index: Int) -> String {
        var modifiedString = String()
        for (i, char) in self.enumerated() {
            modifiedString += String((i == index) ? with : String(char))
        }
        return modifiedString
    }
}


extension Date {

    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

}
