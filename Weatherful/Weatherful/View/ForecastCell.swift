//
//  ForecastCell.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/25/23.
//

import UIKit

class ForecastCell: UICollectionViewCell {

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        overlayView.backgroundColor = .weatherfulLightGrey.withAlphaComponent(0.1)
        overlayView.roundCorners()
        
        guard let captionSmallFont = WeatherfulFonts.forecastSmall else { return }
        guard let captionMediumFont = WeatherfulFonts.forecastMedium else { return }
            dateLabel.configure(font: captionSmallFont)
            timeLabel.configure(font: captionSmallFont)
            tempLabel.configure(font: captionMediumFont)
    }
    
    func configure(date: String, time: String, imageName: String, temp: String) {
        dateLabel.text = date
        timeLabel.text = time
        conditionImageView.image = UIImage(named: imageName)
        tempLabel.text = temp
    }
}
