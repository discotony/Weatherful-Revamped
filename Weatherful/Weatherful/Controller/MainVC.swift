//
//  ViewController.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import UIKit
import Lottie
import CoreLocation
import MapKit
import Contacts

class MainVC: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var resetLocationButton: UIButton!
    
    @IBOutlet weak var weatherAnimationView: LottieAnimationView!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var maxMinTempLabel: UILabel!
    
    @IBOutlet weak var additionalWeatherStackView: UIStackView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var forecastBackgroundView: UIView!
    @IBOutlet weak var forecastHeaderLabel: UILabel!
    @IBOutlet weak var forecastDetailButton: UIButton!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    private var isSearchTriggered: Bool = true // FOLLOWUP
    private var tempUnits: [TempUnits] = [.metric, .imperial] // FOLLOWUP
    
    let settingButton = UIButton()
    private var selectedMenuItemTitle: String?
    private var siteMenuItems:[UIMenuElement] = []
    
    var unit: WeatherfulUnit = .Imperial
    var weatherManager = WeatherManager()
    var currentWeather: WeatherModel?
    var locationManager = CLLocationManager()
    var location: CLLocation?
    
    var conditionName = ""
    var homeLocation = ""
    var requestedLocation = ""
    var didRequestHomeLocation = true
    var forecastArray = [ForecastModel]()
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setUpUI()
        resetPlaceholder()
        weatherManager.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        setUpHeaderCollectionView()
        view.showBlurLoader()
    }
    
    private func setUpNavBar() {
        guard let titleMediumFont = WeatherfulFonts.titleMedium else { return }
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : titleMediumFont, NSAttributedString.Key.foregroundColor : UIColor.weatherfulWhite]
        let settingAttachment = NSTextAttachment()
        settingAttachment.image = UIImage(systemName: "ellipsis.circle")?.withTintColor(.weatherfulWhite)
        settingAttachment.setImageHeight(font: titleMediumFont, height: 20)
        let settingButtonText = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherfulWhite])
        settingButtonText.insert(NSAttributedString(attachment: settingAttachment), at: 0)
        settingButton.setAttributedTitle(settingButtonText, for: .normal)
        settingButton.setTitle("title", for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingButton)
        siteMenuItems = [UIAction(title: "Metric System",
                                  image: UIImage(systemName: "c.circle"),
                                  state: .off,
                                  handler: menuHandler),
                         UIAction(title: "Imperial System",
                                  image: UIImage(systemName: "f.circle"),
                                  state: .on,
                                  handler: menuHandler)]
        setUpMenu(actionTitle: selectedMenuItemTitle)
    }
    
    private func menuHandler(action:UIAction) -> () {
        selectedMenuItemTitle = action.title
        setUpMenu(actionTitle: selectedMenuItemTitle)
    }
    
    private func setUpMenu(actionTitle: String? = nil) {
        let menu = UIMenu(children: siteMenuItems)
        settingButton.menu = updateActionState(actionTitle: actionTitle, menu: menu)
        settingButton.showsMenuAsPrimaryAction = true
    }
    
    private func updateActionState(actionTitle: String? = nil, menu: UIMenu) -> UIMenu {
        if let actionTitle = actionTitle {
            for (index, action) in menu.children.enumerated() {
                if let action = action as? UIAction {
                    if index == 0 {
                        if action.title == actionTitle {
                            if action.state == .off {
                                action.state = .on
                                let imperialAction = menu.children[1] as! UIAction
                                imperialAction.state = .off
                                convertToMetric()
                            }
                        }
                    }
                    if index == 1 {
                        if action.title == actionTitle {
                            if action.state == .off {
                                action.state = .on
                                let metricAction = menu.children[0] as! UIAction
                                metricAction.state = .off
                                convertToImperial()
                            }
                        }
                    }
                }
            }
        }
        return menu
    }
    
    private func convertToMetric() {
        if let weather = currentWeather {
            print("convertToMetric")
            //        weatherConditionLabel.text = currentWeather.conditionDescription.capitalizeFirstLetters
            //        conditionName = currentWeather.animatedConditionName
            unit = .Metric
            currentTempLabel.text = (weather.tempCurrentMetricString) //FOLLOWUP
            maxMinTempLabel.text = "H: \(weather.tempMaxMetricString)  L: \(weather.tempMinMetricString)"
            windLabel.text = weather.windMetricString + " "
            //        humidityLabel.text = currentWeather.humidityString
            forecastCollectionView.reloadData()
        }
    }
    
    private func convertToImperial() {
        if let weather = currentWeather {
            print("convertToImperial")
            //        weatherConditionLabel.text = currentWeather.conditionDescription.capitalizeFirstLetters
            //        conditionName = currentWeather.animatedConditionName
            unit = .Imperial
            currentTempLabel.text = (weather.tempCurrentImperialString) //FOLLOWUP
            maxMinTempLabel.text = "H: \(weather.tempMaxImperialString)  L: \(weather.tempMinImperialString)"
            windLabel.text = weather.windImperialString + " "
            //        humidityLabel.text = currentWeather.humidityString
            forecastCollectionView.reloadData()
        }
        
    }

    @objc func titleButtonPressed(sender: UIButton) {
        performSegue(withIdentifier: K.showSearchIdentifier, sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundImageView.updateBackground() // FOLLOWUP
        forecastCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .right, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func updateConditionImage() {
        let currHour = Date().hour
        var newCondition = conditionName
        
        if conditionName == "" {
            return
        } else if (currHour >= 0 && currHour <= 05) || (currHour >= 22 && currHour <= 24) {
            if conditionName == "clear-day" {
                newCondition = "clear-night"
            } else if conditionName == "party-cloudy-day" {
                newCondition = "party-cloudy-night"
            } else if conditionName == "not-available-day" {
                newCondition = "not-available-night"
            }
        } else {
            if conditionName == "clear-night" {
                newCondition = "clear-day"
            } else if conditionName == "party-cloudy-night" {
                newCondition = "party-cloudy-day"
            } else if conditionName == "not-available-night" {
                newCondition = "not-available-day"
            }
        }
        weatherAnimationView.animation = LottieAnimation.named(newCondition)
        weatherAnimationView.play()
        weatherAnimationView.loopMode = .loop
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConditionImage() // FOLLOWUP
    }
    
    private func setUpUI() {
        guard let titleSmallFont = WeatherfulFonts.titleSmall else { return }
        resetLocationButton.backgroundColor = .weatherfulDarkGrey.withAlphaComponent(0.5)
        resetLocationButton.roundCorners(cornerRadius: resetLocationButton.frame.height / 2)
        resetLocationButton.applyDarkShadow()
        let resetLocationButtonTitle = NSMutableAttributedString(string: "Reset Location", attributes: [NSAttributedString.Key.font : titleSmallFont, NSAttributedString.Key.foregroundColor : UIColor.weatherfulWhite])
        resetLocationButton.setAttributedTitle(resetLocationButtonTitle, for: .normal)
        resetLocationButton.isHidden = true
        
        guard let titleXLFont = WeatherfulFonts.titleXL else { return }
        guard let captionLargeFont = WeatherfulFonts.captionLarge else { return }
        guard let captionMediumFont = WeatherfulFonts.captionMedium else { return }
        weatherConditionLabel.configure(font: captionLargeFont)
        currentTempLabel.configure(font: titleXLFont)
        maxMinTempLabel.configure(font: captionMediumFont)
        windLabel.configure(font: captionMediumFont)
        humidityLabel.configure(font: captionMediumFont)
        
        guard let titleSmallFont = WeatherfulFonts.titleSmall else { return }
        let headerLabelAttachment = NSTextAttachment()
        headerLabelAttachment.image = UIImage(systemName: "chart.xyaxis.line")?.withTintColor(.weatherfulWhite)
        headerLabelAttachment.setImageHeight(font: titleSmallFont, height: 12)
        let headerLabelTitle = NSMutableAttributedString(string: " 24 HR FORECAST")
        headerLabelTitle.insert(NSAttributedString(attachment: headerLabelAttachment), at: 0)
        forecastHeaderLabel.configure(font: titleSmallFont)
        forecastHeaderLabel.attributedText = headerLabelTitle
        
        let forecastButtonAttachment = NSTextAttachment()
        forecastButtonAttachment.image = UIImage(systemName: "chevron.forward")?.withTintColor(.weatherfulWhite)
        forecastButtonAttachment.setImageHeight(font: titleSmallFont, height: 12)
        let forecastButtonTitle = NSMutableAttributedString(string: "Next 5 DAYS ", attributes: [NSAttributedString.Key.font : titleSmallFont])
        forecastButtonTitle.append(NSAttributedString(attachment: forecastButtonAttachment))
        forecastDetailButton.titleLabel?.font = titleSmallFont
        forecastDetailButton.setAttributedTitle(forecastButtonTitle, for: .normal)
    }
    
    private func setNavigationTitle(titleText: String) {
        guard let titleMediumFont = WeatherfulFonts.titleMedium else { return }
        let titleButton = UIButton()
        //        let titleSearchAttachment = NSTextAttachment()
        //        titleSearchAttachment.image = UIImage(named: "icon_location")
        //        titleSearchAttachment.setImageHeight(font: titleMediumFont, height: 14)
        let titleDropdownAttachment = NSTextAttachment()
        titleDropdownAttachment.image = UIImage(named: "icon_dropdown")
        titleDropdownAttachment.setImageHeight(font: titleMediumFont, height: 14)
        let titleText = NSMutableAttributedString(string: "  \(titleText)  ", attributes: [NSAttributedString.Key.font : titleMediumFont, NSAttributedString.Key.foregroundColor : UIColor.weatherfulWhite])
        //        titleText.insert(NSAttributedString(attachment: titleSearchAttachment), at: 0)
        titleText.append(NSAttributedString(attachment: titleDropdownAttachment))
        titleButton.setAttributedTitle(titleText, for: .normal)
        titleButton.addTarget(self, action: #selector(titleButtonPressed), for: .touchUpInside)
        
        navigationItem.titleView = titleButton
    }
    
    private func resetPlaceholder() {
        weatherConditionLabel.text = ""
        currentTempLabel.text = ""
        maxMinTempLabel.text = ""
        windLabel.text = ""
        humidityLabel.text = ""
    }
    
    private func setUpHeaderCollectionView() {
        forecastCollectionView.dataSource = self
        forecastCollectionView.delegate = self
        forecastCollectionView.register(UINib(nibName: K.forecastCellNibName, bundle: nil), forCellWithReuseIdentifier: K.forecastCellIdentifier)
        forecastCollectionView.showsHorizontalScrollIndicator = false
        forecastCollectionView.collectionViewLayout = setFlowLayout()
    }
    
    private func setFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 16
        return flowLayout
    }
    
    // MARK: - IBActions
    @IBAction func resetLocationButtonPressed(_ sender: Any) {
        locationManager.requestLocation()
        resetLocationButton.isHidden = true
        view.showBlurLoader()
    }
    
    @IBAction func forecastDetailButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.showForecastIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.showForecastIdentifier {
            let destinationVC = segue.destination as! ForecastVC
            destinationVC.forecastArray = forecastArray
            destinationVC.location = requestedLocation
            destinationVC.unit = unit
        } else if segue.identifier == K.showSearchIdentifier {
            let destinationNavVC = segue.destination as! UINavigationController
            let destinationVC = destinationNavVC.topViewController as! SearchVC
            destinationVC.delegate = self
        }
    }
}

/*
 // MARK: - UITextFieldDelegate
 extension MainVC: UITextFieldDelegate {
 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
 //        print("textFieldShouldReturn: " + searchTextField.text!)
 self.view.endEditing(true) //FOLLOWUP
 return true
 
 }
 
 // Input Validation
 func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
 if textField.text != "" {
 return true
 } else {
 self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Make sure to enter a city name!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherWarningRed, NSAttributedString.Key.font : WeatherfulFonts.captionMedium!])
 Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { Timer in
 self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Look up weather by city name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherfulPlaceholderGrey, NSAttributedString.Key.font : WeatherfulFonts.captionMedium!])
 }
 textField.shake()
 return false
 }
 }
 
 func textFieldDidEndEditing(_ textField: UITextField) {
 if let cityName = searchTextField.text {
 let formattedCityName = String((cityName as NSString).replacingOccurrences(of: " ", with: "+"))
 //            print("textFieldDidEndEditing " + formattedCityName)
 weatherManager.fetchWeather(from: formattedCityName)
 }
 
 searchTextField.text = ""
 self.hideSearchBar()
 view.showBlurLoader()
 }
 }
 */

// MARK: - WeatherManagerDelegate
extension MainVC: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async { //FOLLOWUP
            self.currentWeather = weather
            self.weatherConditionLabel.text = weather.conditionDescription.capitalizeFirstLetters
            self.conditionName = weather.animatedConditionName
            self.updateConditionImage()
            self.currentTempLabel.text = (weather.tempCurrentImperialString) //FOLLOWUP
            self.maxMinTempLabel.text = "H: \(weather.tempMaxImperialString)  L: \(weather.tempMinImperialString)"
            self.windLabel.text = weather.windImperialString + " "
            self.humidityLabel.text = weather.humidityString
            print("homecity: " + self.homeLocation)
            print("weather.cityName: " + weather.city)
            self.resetLocationButton.isHidden = self.requestedLocation == self.homeLocation ? true : false
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { Timer in
                self.view.removeBluerLoader()
            }
        }
    }
    
    func didUpdateForecast(_ weatherManager: WeatherManager, forecast: [ForecastModel]) {
        DispatchQueue.main.async {
            self.forecastArray = forecast
            self.forecastCollectionView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
        DispatchQueue.main.async {
            self.view.removeBluerLoader()
            //            self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Please enter a valid city name!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            //            self.searchTextField.becomeFirstResponder()
            //            self.searchTextField.shake()
            //            self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Error: Invalid City Name!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherWarningRed, NSAttributedString.Key.font : WeatherfulFonts.captionMedium!])
            //            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { Timer in
            //                self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Look up weather by city name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherfulPlaceholderGrey, NSAttributedString.Key.font : WeatherfulFonts.captionMedium!])
            //            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MainVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latestLocation = locations.last {
            let latitude = latestLocation.coordinate.latitude
            let longitude = latestLocation.coordinate.longitude
            locationManager.stopUpdatingLocation() //FOLLOWUP
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            location.placemark { placemark, error in
                guard let placemark = placemark else {
                    print("Error:", error ?? "nil")
                    return
                }
                if let location = placemark.locationFormatted {
                    self.requestedLocation = location
                    self.homeLocation = location
                    self.setNavigationTitle(titleText: location)
                }
            }
            weatherManager.fetchWeatherData(with: latestLocation.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - UICollectionViewDataSource
extension MainVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = forecastCollectionView.dequeueReusableCell(withReuseIdentifier: K.forecastCellIdentifier, for: indexPath) as! ForecastCell
        
        if !forecastArray.isEmpty {
            let forecast = forecastArray[indexPath.row]
            if unit == .Metric {
                cell.configure(date: forecast.dateShort, time: forecast.time, imageName: forecast.conditionImageName, temp: forecast.tempMetricString)
            } else {
                cell.configure(date: forecast.dateShort, time: forecast.time, imageName: forecast.conditionImageName, temp: forecast.tempImperialString)
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 160)
    }
}


// MARK: - UICollectionViewDelegate
extension MainVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
}

// MARK: - Other Extensions
extension CLPlacemark {
    /// street name, eg. Infinite Loop
    var streetName: String? { thoroughfare }
    /// // eg. 1
    var streetNumber: String? { subThoroughfare }
    /// city, eg. Cupertino
    var city: String? { locality }
    /// neighborhood, common name, eg. Mission District
    var neighborhood: String? { subLocality }
    /// state, eg. CA
    var state: String? { administrativeArea }
    /// county, eg. Santa Clara
    //    var county: String? { subAdministrativeArea }
    private var area: String? {
        if self.country == "United States" {
            return administrativeArea
        } else {
            return subAdministrativeArea
        }
    }
    var locationFormatted: String? {
        if let city = city, let area = area {
            return "\(city), \(area)"
        } else {
            return nil
        }
    }
    /// zip code, eg. 95014
    var zipCode: String? { postalCode }
    /// postal address formatted
    @available(iOS 11.0, *)
    var postalAddressFormatted: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter().string(from: postalAddress)
    }
}

extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}

extension Date {
    var hour: Int { return Calendar.current.component(.hour, from: self) }
}

extension NSTextAttachment {
    func setImageHeight(font: UIFont, height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height
        
        bounds = CGRect(x: bounds.origin.x, y: (font.capHeight - height.rounded()) / 2, width: ratio * height, height: height)
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension MainVC: SearchVCDelegate {
    func didFetchCoordinates(cityName: String, with coordinates: CLLocationCoordinate2D) {
        print(coordinates)
        print(cityName)
        setNavigationTitle(titleText: cityName)
        requestedLocation = cityName
        
        print("lat: \(coordinates.latitude)")
        print("lon: \(coordinates.longitude)")
        weatherManager.fetchWeatherData(with: coordinates)
    }
}
