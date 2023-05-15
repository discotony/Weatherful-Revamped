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
        navigationController?.interactivePopGestureRecognizer?.delegate = self

//        navigationController?.navigationBar.tintColor = .weatherfulWhite
        
//        preferredStatusBarStyle = .lightContent
        
        guard let titleMediumFont = WeatherfulFonts.titleMedium else { return }
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : titleMediumFont, NSAttributedString.Key.foregroundColor : UIColor.weatherfulWhite]
        self.title = locationName
        
        
        let backButton = UIButton()
            
        let backButtonAttachment = NSTextAttachment()
        backButtonAttachment.image = UIImage(named: "icon_left_arrow")
        backButtonAttachment.setImageHeight(font: titleMediumFont, height: 14)
        let backButtonTitle = NSMutableAttributedString(string: " Back", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherfulWhite])
        backButtonTitle.insert(NSAttributedString(attachment: backButtonAttachment), at: 0)
        
        
        backButton.setAttributedTitle(backButtonTitle, for: .normal)
        backButton.addTarget(self, action: #selector(btnLeftNavigationClicked), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func btnLeftNavigationClicked(sender: UIButton) {
            guard let navigationController = self.navigationController else {
                return
            }
            navigationController.popViewController(animated: true)
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
        
//        forecastTableView.sectionHeaderHeight = 0
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
            headerCell.configure(date: forecastGroup[0][0].dateExpanded)
        case .dayTwo:
            headerCell.configure(date: forecastGroup[1][0].dateExpanded)
        case .dayThree:
            headerCell.configure(date: forecastGroup[2][0].dateExpanded)
        case .dayFour:
            headerCell.configure(date: forecastGroup[3][0].dateExpanded)
        case .dayFive:
            headerCell.configure(date: forecastGroup[4][0].dateExpanded)
        }
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = forecastTableView.dequeueReusableCell(withIdentifier: K.forecastDetailCellIdentifier, for: indexPath) as! ForecastDetailCell
        
        let sectionType = sections[indexPath.section]
        switch sectionType {
        case .dayOne:
            let forecast = forecastGroup[0][indexPath.row]
            cell.configure(time: forecast.time, imageName: forecast.conditionImageName, condition: forecast.conditionDescription, temp: forecast.tempString)
            if indexPath.row == forecastGroup[0].count - 1 {
                cell.borderView.isHidden = true
            } else {
                cell.borderView.isHidden = false
            }
        case .dayTwo:
            let forecast = forecastGroup[1][indexPath.row]
            cell.configure(time: forecast.time, imageName: forecast.conditionImageName, condition: forecast.conditionDescription, temp: forecast.tempString)
        case .dayThree:
            let forecast = forecastGroup[2][indexPath.row]
            cell.configure(time: forecast.time, imageName: forecast.conditionImageName, condition: forecast.conditionDescription, temp: forecast.tempString)
        case .dayFour:
            let forecast = forecastGroup[3][indexPath.row]
            cell.configure(time: forecast.time, imageName: forecast.conditionImageName, condition: forecast.conditionDescription, temp: forecast.tempString)
        case .dayFive:
            let forecast = forecastGroup[4][indexPath.row]
            cell.configure(time: forecast.time, imageName: forecast.conditionImageName, condition: forecast.conditionDescription, temp: forecast.tempString)
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
//        return 40
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
        return mask
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


extension ForecastVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
