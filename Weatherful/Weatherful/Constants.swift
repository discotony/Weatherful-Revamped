//
//  Constants.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/25/23.
//

import Foundation

struct K {
    static let appName = "Weatherful"
    
    static let dateCellIdentifier = String(describing: DateCell.self)
    static let dateCellNibName = String(describing: DateCell.self)
    
    
    static let forecastCellIdentifier = String(describing: ForecastCell.self)
    static let forecastCellNibName = String(describing: ForecastCell.self)
    
    static let forecastHeaderCellIdentifier = String(describing: ForecastHeaderCell.self)
    static let forecastHeaderNibName = String(describing: ForecastHeaderCell.self)
    static let forecastDetailCellIdentifier = String(describing: ForecastDetailCell.self)
    static let forecastDetailNibName = String(describing: ForecastDetailCell.self)
    
    static let showForecastDetailIdentifier = "showForecastDetail"
}
