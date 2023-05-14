//
//  ForecastDetailCell.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/13/23.
//

import UIKit

class ForecastDetailCell: UITableViewCell {

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    private func setUpUI() {
        self.backgroundColor = .clear
        overlayView.backgroundColor = .clear
//        overlayView.backgroundColor = .weatherfulLightGrey.withAlphaComponent(0.1)
//        overlayView.roundCorners()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
