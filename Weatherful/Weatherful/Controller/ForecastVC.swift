//
//  ForecastVC.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/13/23.
//

import UIKit

class ForecastVC: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var forecastTableView: UITableView!
    
    var forecastArray = [ForecastModel]()
    var forecastGroup = [[ForecastModel]]()
    var locationName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()
        setUpUI()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundImageView.updateBackground()
    }
    
    private func setUpNavBar() {
        //FOLLOWUP Customize font sizes
        navigationController?.navigationBar.tintColor = .weatherfulWhite
        self.title = locationName
        
    }
    
    private func setUpUI() {
    }
    
    private func setUpTableView() {
        forecastTableView.dataSource = self
        forecastTableView.delegate = self
        forecastTableView.register(UINib(nibName: K.forecastDetailNibName, bundle: nil), forCellReuseIdentifier: K.forecastDetailCellIdentifier)
        forecastTableView.register(UINib(nibName: K.forecastHeaderNibName, bundle: nil), forCellReuseIdentifier: K.forecastHeaderCellIdentifier)
        
        forecastTableView.backgroundColor = .clear
//        forecastTableView.separatorColor = .clear
        forecastTableView.separatorColor = .weatherfulLightGrey.withAlphaComponent(0.1)
    }
}

// MARK: - UITableViewDataSource
extension ForecastVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
        let headerCell = forecastTableView.dequeueReusableCell(withIdentifier: K.forecastHeaderCellIdentifier) as! ForecastHeaderCell
//        headerView.addSubview(headerCell)
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = forecastTableView.dequeueReusableCell(withIdentifier: K.forecastDetailCellIdentifier, for: indexPath) as! ForecastDetailCell
        
        let forecast = forecastArray[indexPath.row]
        cell.timeLabel.text = forecast.timeString
        cell.conditionImageView.image = UIImage(named: forecast.staticConditionName)
        cell.conditionDescriptionLabel.text = forecast.conditionDescription
        cell.tempLabel.text = forecast.tempString
//        cell.windLabel.text = forecast.windString
//        cell.humidityLabel.text = forecast.humidityString
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


// MARK: - Section HeadingUITableViewDelegate
extension ForecastVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in forecastTableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + navigationController!.navigationBar.frame.size.height - cell.frame.origin.y - 1
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                maskCell(cell: cell, margin: Float(hiddenFrameHeight))
            }
        }
    }
    
    func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }

    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        tableView.cellForRow(at: indexPath)?.backgroundColor = . systemTeal
    }
}

