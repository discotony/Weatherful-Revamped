//
//  ForecastHeaderCell.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/13/23.
//

import UIKit

class ForecastHeaderCell: UITableViewCell {
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        overlayView.backgroundColor = .weatherfulLightGrey.withAlphaComponent(0.1)
        overlayView.roundCorners(cornerRadius: 15)
        
        guard let forecastMediumFont = WeatherfulFonts.forecastMedium else { return }
        dateLabel.configure(font: forecastMediumFont)
    }
    
    func configure(date: String) {
        dateLabel.text = date
    }
}
