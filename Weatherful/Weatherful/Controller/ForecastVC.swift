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
    
    enum SectionType {
        case dayOne
        case dayTwo
        case dayThree
        case dayFour
        case dayFive
    }
    
    var sections: [SectionType] = [.dayOne, .dayTwo, .dayThree, .dayFour, .dayFive]
    
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
        forecastTableView.showsVerticalScrollIndicator = false
        //        forecastTableView.separatorColor = .weatherfulLightGrey.withAlphaComponent(0.2)
        forecastTableView.separatorColor = . clear
        
    }
}

// MARK: - UITableViewDataSource
extension ForecastVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count //FOLLOWUP
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sections[section]
        switch sectionType {
        case .dayOne:
            return forecastGroup[0].count
        case .dayTwo:
            return forecastGroup[1].count
        case .dayThree:
            return forecastGroup[2].count
        case .dayFour:
            return forecastGroup[3].count
        case .dayFive:
            return forecastGroup[5].count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //        let headerView = UIView()
        let headerCell = forecastTableView.dequeueReusableCell(withIdentifier: K.forecastHeaderCellIdentifier) as! ForecastHeaderCell
        //        headerView.addSubview(headerCell)
        
        
        let sectionType = sections[section]
        switch sectionType {
        case .dayOne:
            headerCell.configure(text: forecastGroup[0][0].dateCompleteString)
        case .dayTwo:
            headerCell.configure(text: forecastGroup[1][0].dateCompleteString)
        case .dayThree:
            headerCell.configure(text: forecastGroup[2][0].dateCompleteString)
        case .dayFour:
            headerCell.configure(text: forecastGroup[3][0].dateCompleteString)
        case .dayFive:
            headerCell.configure(text: forecastGroup[4][0].dateCompleteString)
        }
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = forecastTableView.dequeueReusableCell(withIdentifier: K.forecastDetailCellIdentifier, for: indexPath) as! ForecastDetailCell
        
        let sectionType = sections[indexPath.section]
        switch sectionType {
        case .dayOne:
            let forecast = forecastGroup[0][indexPath.row]
            cell.configure(time: forecast.timeString, imageName: forecast.staticConditionName, condition: forecast.conditionDescription, temp: forecast.tempString)
        case .dayTwo:
            let forecast = forecastGroup[1][indexPath.row]
            cell.configure(time: forecast.timeString, imageName: forecast.staticConditionName, condition: forecast.conditionDescription, temp: forecast.tempString)
        case .dayThree:
            let forecast = forecastGroup[2][indexPath.row]
            cell.configure(time: forecast.timeString, imageName: forecast.staticConditionName, condition: forecast.conditionDescription, temp: forecast.tempString)
        case .dayFour:
            let forecast = forecastGroup[3][indexPath.row]
            cell.configure(time: forecast.timeString, imageName: forecast.staticConditionName, condition: forecast.conditionDescription, temp: forecast.tempString)
        case .dayFive:
            let forecast = forecastGroup[4][indexPath.row]
            cell.configure(time: forecast.timeString, imageName: forecast.staticConditionName, condition: forecast.conditionDescription, temp: forecast.tempString)
        }
        
        
        //        cell.windLabel.text = forecast.windString
        //        cell.humidityLabel.text = forecast.humidityString
        
        
        
        // FOLLOWUP
//        let bottomBorder = CALayer()
//        if indexPath.row > 0 && indexPath.row < forecastArray.count  {
//            bottomBorder.frame = CGRect(x: 16, y: 0, width: cell.contentView.frame.size.width - 32, height: 1.0)
//            bottomBorder.backgroundColor = UIColor.weatherfulLightGrey.withAlphaComponent(0.1).cgColor
//            cell.contentView.layer.addSublayer(bottomBorder)
//        }
        
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
        performSegue(withIdentifier: K.showForecastDetailIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.showForecastDetailIdentifier {
            let destinationVC = segue.destination as! ForecastDetailVC
            destinationVC.view.backgroundColor = .systemTeal
        }
    }

}
