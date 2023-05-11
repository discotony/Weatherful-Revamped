//
//  DateCell.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/25/23.
//

import UIKit

class DateCell: UICollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let captionSmallFont = WeatherfulFonts.titleSmall {
            dateLabel.configure(font: captionSmallFont, color: .weatherfulLightGrey)
        }
        dateLabel.textAlignment = .left
    }
}
