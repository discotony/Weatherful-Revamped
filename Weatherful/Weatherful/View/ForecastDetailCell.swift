//
//  ForecastDetailCell.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/13/23.
//

import UIKit

class ForecastDetailCell: UITableViewCell {
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        overlayView.backgroundColor = .clear
        borderView.backgroundColor = .weatherfulLightGrey.withAlphaComponent(0.1)
        borderView.roundCorners()
        
        guard let forecastSmallFont = WeatherfulFonts.forecastSmall else { return }
        guard let forecastMediumFont = WeatherfulFonts.forecastMedium else { return }
        timeLabel.configure(font: forecastSmallFont)
        conditionDescriptionLabel.configure(font: forecastMediumFont)
        tempLabel.configure(font: forecastMediumFont)
    }
    
    func configure(time: String, imageName: String, condition: String, temp: String) {
        timeLabel.text = time
        conditionImageView.image = UIImage(named: imageName)
        conditionDescriptionLabel.text = condition
        tempLabel.text = temp
    }
}
