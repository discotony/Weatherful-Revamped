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
        setUpUI()
    }
    
    private func setUpUI() {
        overlayView.backgroundColor = .weatherfulLightGrey.withAlphaComponent(0.1)
        overlayView.roundCorners(cornerRadius: 15)
        
        
        guard let forecastMediumFont = WeatherfulFonts.forecastMedium else { return }
        guard let forecastLargeFont = WeatherfulFonts.forecastLarge else { return }
        dateLabel.configure(font: forecastMediumFont)
    }
    
    func configure(text: String) {
        dateLabel.text = text
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}



//enum headerType {
//    case feed
//    case profile
//}

//class FeedCollectionViewHeader: UICollectionReusableView {
//    @IBOutlet weak var headerLabel: UILabel!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    // MARK: - Configure Method
//
