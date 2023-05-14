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
        overlayView.roundCorners(cornerRadius: 20)
        dateLabel.text = "Today, May 7"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
