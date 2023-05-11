//
//  ForecastCell.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/25/23.
//

import UIKit

class ForecastCell: UICollectionViewCell {

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        overlayView.backgroundColor = .weatherfulLightGrey.withAlphaComponent(0.1)
        overlayView.roundCorners()
        
        if let captionSmallFont = WeatherfulFonts.forecastSmall {
            timeLabel.configure(font: captionSmallFont)
        }
        if let captionMediumFont = WeatherfulFonts.forecastMedium {
            tempLabel.configure(font: captionMediumFont)
        }
    }
}
