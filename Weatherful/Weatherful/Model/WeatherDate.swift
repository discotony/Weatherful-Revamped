//
//  WeatherDate.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/14/23.
//

import Foundation

enum Format {
    case shortened
    case full
}

struct WeatherDate {
    let timestamp: Double
    
    private var formattedTimestamp: String {
        Date(timeIntervalSince1970: TimeInterval(timestamp)).toLocalTime().description
    }
    
    // 5/14
    private var date: String {
        return formatDate(timestamp: formattedTimestamp)
    }
    
    // Sun
    private var day: String {
        return getDayOfWeekString(date: formattedTimestamp)
    }
    
    // 5/14
    var dateShort: String {
        return "\(day), \(date)"
    }
    
    //  Sun, 5/14
    var dateFull: String {
        return formatFullDate(timestamp: formattedTimestamp)
    }
    
    // Sunday, May 14
    var dateExpanded: String {
        let day = dateShort.prefix(3)
        switch day {
        case "Sun":
            return "Sunday" + ", " + dateFull
        case "Mon":
            return "Monday" + ", " + dateFull
        case "Tue":
            return "Tuesday" + ", " + dateFull
        case "Wed":
            return "Wednesday" + ", " + dateFull
        case "Thu":
            return "Thursday" + ", " + dateFull
        case "Fri":
            return "Friday" + ", " + dateFull
        case "Sat":
            return "Saturday" + ", " + dateFull
        default:
            print("Error fetching days")
            return "Day"
        }
    }
    
    // 8 PM
    var time: String {
        return formatTime(time: String(Array(formattedTimestamp)[11...15]))
    }
    
    private func formatDate(timestamp: String) -> String {
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
    
    private func getDayOfWeekString(date: String) -> String {
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
    
    private func formatFullDate(timestamp: String) -> String {
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
    
    private func formatTime(time: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        let date12 = dateFormatter.date(from: time)!
        
        dateFormatter.dateFormat = "h:mm a"
        let date22 = dateFormatter.string(from: date12).replacingOccurrences(of: ":00", with: "")
        return date22
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
