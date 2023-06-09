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
    
    var unit: WeatherfulUnit?
    var forecastArray = [ForecastModel]()
    var forecastDateArray = [String]()
    var forecastGroup = [[ForecastModel]]()
    var numForecastDates = 0
    var location = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forecastDateArray = getDateGroup(forecastArray: forecastArray)
        numForecastDates = forecastDateArray.count
        forecastGroup = groupForecast(forecastArray: forecastArray)
        
        setUpNavBar()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundImageView.updateBackground()
    }
    
    private func setUpNavBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        guard let titleMediumFont = WeatherfulFonts.titleMedium else { return }
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : titleMediumFont, NSAttributedString.Key.foregroundColor : UIColor.weatherfulWhite]
        self.title = location
        
        let backButton = UIButton()
        let backButtonAttachment = NSTextAttachment()
        backButtonAttachment.image = UIImage(named: "icon_left_arrow")
        backButtonAttachment.setImageHeight(font: titleMediumFont, height: 14)
        let backButtonTitle = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherfulWhite])
        backButtonTitle.insert(NSAttributedString(attachment: backButtonAttachment), at: 0)
        backButton.setAttributedTitle(backButtonTitle, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func backButtonPressed(sender: UIButton) {
        guard let navigationController = self.navigationController else { return }
        navigationController.popViewController(animated: true)
    }
    
    private func setUpTableView() {
        forecastTableView.dataSource = self
        forecastTableView.delegate = self
        
        forecastTableView.register(UINib(nibName: K.forecastDetailNibName, bundle: nil), forCellReuseIdentifier: K.forecastDetailCellIdentifier)
        forecastTableView.register(UINib(nibName: K.forecastHeaderNibName, bundle: nil), forCellReuseIdentifier: K.forecastHeaderCellIdentifier)
        
        forecastTableView.backgroundColor = .clear
        forecastTableView.showsVerticalScrollIndicator = false
        forecastTableView.separatorColor = . clear
//        forecastTableView.contentInsetAdjustmentBehavior = .never
//        forecastTableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
//        forecastTableView.automaticallyAdjustsScrollIndicatorInsets = false
        forecastTableView.sectionHeaderTopPadding = 0
    }
    
    private func getDateGroup(forecastArray: [ForecastModel]) -> [String] {
        var dateArray = [String]()
        for forecast in forecastArray {
            dateArray.append(forecast.dateShort)
        }
        return dateArray.uniqued()
    }
    
    private func groupForecast(forecastArray: [ForecastModel]) -> [[ForecastModel]] {
        var forecastGroup = [[ForecastModel]]()
        
        for i in forecastDateArray.indices {
            forecastGroup.append([ForecastModel]())
            for forecast in forecastArray {
                if forecastDateArray[i] == forecast.dateShort {
                    forecastGroup[i].append(forecast)
                }
            }
        }
        return forecastGroup
    }
}

// MARK: - UITableViewDataSource
extension ForecastVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numForecastDates
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastGroup[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = forecastTableView.dequeueReusableCell(withIdentifier: K.forecastHeaderCellIdentifier) as! ForecastHeaderCell
        headerCell.configure(date: forecastGroup[section][0].dateExpanded)
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = forecastTableView.dequeueReusableCell(withIdentifier: K.forecastDetailCellIdentifier, for: indexPath) as! ForecastDetailCell
        let forecast = forecastGroup[indexPath.section][indexPath.row]
        if unit == .Metric {
            cell.configure(time: forecast.time, imageName: forecast.conditionImageName, condition: forecast.conditionDescription, temp: forecast.tempMetricString)
        } else {
            cell.configure(time: forecast.time, imageName: forecast.conditionImageName, condition: forecast.conditionDescription, temp: forecast.tempImperialString)
        }
        let isLastCell = indexPath.row == forecastGroup[indexPath.section].count - 1
        cell.borderView.isHidden = isLastCell ? true : false
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


// MARK: - UITableViewDelegate
extension ForecastVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in forecastTableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 0) - cell.frame.origin.y - 1
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                maskCell(cell: cell, margin: Float(hiddenFrameHeight))
            }
        }
    }
    
    private func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }
    
    private func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ForecastVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
