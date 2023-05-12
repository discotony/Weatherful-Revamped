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
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var dropdownSymbol: UIImageView!
    
    @IBOutlet weak var resetLocationButton: UIButton!
    @IBOutlet weak var tappableView: UIView!
    
    @IBOutlet weak var weatherAnimationView: LottieAnimationView!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var maxMinTempLabel: UILabel!
    
    @IBOutlet weak var additionalWeatherStackView: UIStackView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var forecastBackgroundView: UIView!
    @IBOutlet weak var dateCollectionView: UICollectionView!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    private var isSearchTriggered: Bool = true
    private var tempUnits: [tempUnits] = [.metric, .imperial]
    
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    var location: CLLocation?
    
    var conditionName = ""
    var homeCity = ""
    var didRequestHomeLocation = true
    var forecastArray = [ForecastModel]()
    var forecastGroup = [[ForecastModel]]()
    var forecastDateArray = [String]()
    
    var selectedForcastGroup = 0
    
    var timer = Timer()
    
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
        setUpUI()
        resetPlaceholder()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        forecastCollectionView.dataSource = self
        forecastCollectionView.delegate = self
        setUpHeaderCollectionView()
        
        view.showBlurLoader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //        let selectedIndexPath = IndexPath(item: 0, section: 0)
        //        dateCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .right)
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
        
        updateConditionImage()
        
//        NSIndexPath *indexPathForFirstRow = [NSIndexPath indexPathForRow:0 inSection:0];
//        [self.dateCollectionView selectItemAtIndexPath:indexPathForFirstRow animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//        [self collectionView:self.dateCollectionView didSelectItemAtIndexPath:indexPathForFirstRow];
//        
        
//        self.dateCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .right)
    }
    
    //    private func setUpAppIcon() {
    //        if #available(iOS 13.0, *) {
    //            if self.traitCollection.userInterfaceStyle == .dark {
    //               UIApplication.shared.setAlternateIconName("AppIcon-DarkMode")
    //            } else {
    //                UIApplication.shared.setAlternateIconName(nil)
    //            }
    //        }
    //    }
    
    private func setUpUI() {
        changeBackground()
        headerView.backgroundColor = .clear
        self.headerView.roundCorners()
        guard let titleLargeFont = WeatherfulFonts.titmeLarge else { return }
        cityLabel.configure(font: titleLargeFont)
        searchTextField.backgroundColor = .clear
        searchTextField.textColor = .weatherfulWhite
        searchTextField.tintColor = .weatherfulPlaceholderGrey
        searchTextField.borderStyle = .none
        searchTextField.font = WeatherfulFonts.captionMedium
        
        resetLocationButton.backgroundColor = .weatherfulDarkGrey.withAlphaComponent(0.5)
        resetLocationButton.titleLabel?.font = WeatherfulFonts.captionMedium
        resetLocationButton.roundCorners(cornerRadius: resetLocationButton.frame.height / 2)
        resetLocationButton.applyDarkShadow()
        resetLocationButton.isHidden = true
        
        guard let titleXLFont = WeatherfulFonts.titleXL else { return }
        guard let captionLargeFont = WeatherfulFonts.captionLarge else { return }
        guard let captionMediumFont = WeatherfulFonts.captionMedium else { return }
        weatherConditionLabel.configure(font: captionLargeFont)
        currentTempLabel.configure(font: titleXLFont)
        maxMinTempLabel.configure(font: captionMediumFont)
        windLabel.configure(font: captionMediumFont)
        humidityLabel.configure(font: captionMediumFont)
    }
    
    private func changeBackground(){
        switch Date().hour {
        case 00...04:
            backgroundImageView.image = UIImage(named: "00-04")
        case 5:
            backgroundImageView.image = UIImage(named: "05")
        case 6...7:
            backgroundImageView.image = UIImage(named: "06-07")
        case 8...9:
            backgroundImageView.image = UIImage(named: "08-09")
        case 10...11:
            backgroundImageView.image = UIImage(named: "10-11")
        case 12...15:
            backgroundImageView.image = UIImage(named: "12-15")
        case 16...18:
            backgroundImageView.image = UIImage(named: "16-18")
        case 19:
            backgroundImageView.image = UIImage(named: "19")
        case 20:
            backgroundImageView.image = UIImage(named: "20")
        case 21:
            backgroundImageView.image = UIImage(named: "21")
        case 22...24: // FOLLOWUP
            backgroundImageView.image = UIImage(named: "22-23")
        default:
            break
        }
    }
    
    private func resetPlaceholder() {
        cityLabel.text = ""
        weatherConditionLabel.text = ""
        currentTempLabel.text = ""
        maxMinTempLabel.text = ""
        windLabel.text = ""
        humidityLabel.text = ""
    }
    
    private func setUpPlaceholder() {
        cityLabel.text = "San Francisco"
        weatherConditionLabel.text = "Heavy Snow"
        currentTempLabel.text = "72°F"
        maxMinTempLabel.text = "Wind: 15 km/h, Humidty: 43%"
    }
    
    private func setUpHeaderCollectionView() {
        dateCollectionView.register(UINib(nibName: K.dateCellNibName, bundle: nil), forCellWithReuseIdentifier: K.dateCellIdentifier) //FOLLOWUP
        dateCollectionView.showsHorizontalScrollIndicator = false
        dateCollectionView.collectionViewLayout = setFlowLayout()
        
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
    
    
    // MARK: - Dark Mode Support
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //        print (traitCollection.userInterfaceStyle == .dark)
        if traitCollection.userInterfaceStyle == .dark {
            self.weatherAnimationView.animation = LottieAnimation.named("clear-night")
            self.weatherAnimationView.play()
            self.weatherAnimationView.loopMode = .loop
        } else {
            self.weatherAnimationView.animation = LottieAnimation.named("clear-day")
            self.weatherAnimationView.play()
            self.weatherAnimationView.loopMode = .loop
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        if isSearchTriggered {
            self.showSearchBar()
        } else {
            self.hideSearchBar()
        }
        isSearchTriggered = !isSearchTriggered
    }
    
    private func showSearchBar() {
        UIView.animate(withDuration: 0.5) {
            self.headerView.backgroundColor = .weatherfulWhite.withAlphaComponent(0.2)
            self.cityLabel.isHidden = true
            self.dropdownSymbol.isHidden = true
            self.iconImageView.image = UIImage(named: "icon_search.png")
            self.searchTextField.isHidden = false
            guard let captionMediumFont = WeatherfulFonts.captionMedium else { return }
            self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Look up weather by city name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherfulPlaceholderGrey, NSAttributedString.Key.font : captionMediumFont])
            self.tappableView.isHidden = true
        }
    }
    
    private func hideSearchBar() {
        UIView.animate(withDuration: 0.5) {
            self.headerView.backgroundColor = .clear
            self.cityLabel.isHidden = false
            self.dropdownSymbol.isHidden = false
            self.iconImageView.image = UIImage(named: "icon_location.png")
            self.searchTextField.isHidden = true
            self.tappableView.isHidden = false
        }
    }
    
    @IBAction func resetLocationButtonPressed(_ sender: Any) {
        locationManager.requestLocation()
        resetLocationButton.isHidden = true
        view.showBlurLoader()
    }
}

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
        didRequestHomeLocation = false
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

// MARK: - WeatherManagerDelegate

extension MainVC: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async { //FOLLOWUP
            
            self.cityLabel.text = weather.cityName
            
            let location = CLLocation(latitude: weather.coordinates.lat, longitude: weather.coordinates.lon)
            location.placemark { placemark, error in
                guard let placemark = placemark else {
                    print("Error:", error ?? "nil")
                    return
                }
                if var area = placemark.country {
                    if area == "United States" {
                        if let state = placemark.state {
                            area = state
                        } else {
                            area = "US"
                        }
                    }
                    self.cityLabel.text?.append(", \(area)")
                }
            }
            self.weatherConditionLabel.text = weather.conditionDescription.capitalizeFirstLetters
            self.conditionName = weather.animatedConditionName
            self.updateConditionImage()
            self.currentTempLabel.text = (weather.tempCurrentString) //FOLLOWUP
            self.maxMinTempLabel.text = "H: \(weather.tempMaxString)  L: \(weather.tempMinString)"
            self.windLabel.text = weather.windString + " "
            self.humidityLabel.text = weather.humidityString
            
            self.resetLocationButton.isHidden = weather.cityName == self.homeCity ? true : false
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { Timer in
                self.view.removeBluerLoader()
            }
        }
    }
    
    func didUpdateForecast(_ weatherManager: WeatherManager, forecast: [ForecastModel]) {
        DispatchQueue.main.async {
            self.forecastArray = forecast
            
            var dateArray = [String]()
            var index = 0
            while (index < forecast.count) {
                //                print("date" + forecastArray[index].dateString)
                dateArray.append(forecast[index].dateString)
                index += 1
            }
            print("datearray: \(dateArray)")
            self.forecastDateArray = dateArray.uniqued()
            print("unique dates: \(self.forecastDateArray)")
            
            self.forecastGroup = self.groupForecast(forecastArray: forecast)

            
            self.dateCollectionView.reloadData()
//            self.dateCollectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: .right)

            self.forecastCollectionView.reloadData()
        }
    }
    
    private func groupForecast(forecastArray: [ForecastModel]) -> [[ForecastModel]] {
        var forecastGroup = [[ForecastModel]]()
        var groupOne = [ForecastModel]()
        var groupTwo = [ForecastModel]()
        var groupThree = [ForecastModel]()
        var groupFour = [ForecastModel]()
        var groupFive = [ForecastModel]()
        var groupSix = [ForecastModel]()
        
        print("forecastArray.count: \(forecastArray.count)")
        print("forecastDateArray.count: \(forecastDateArray.count)")
        print("")
        for forecast in forecastArray {
            if forecast.dateString == forecastDateArray[0] {
                groupOne.append(forecast)
            } else if forecast.dateString == forecastDateArray[1] {
                groupTwo.append(forecast)
            } else if forecast.dateString == forecastDateArray[2] {
                groupThree.append(forecast)
            } else if forecast.dateString == forecastDateArray[3] {
                groupFour.append(forecast)
            } else if forecast.dateString == forecastDateArray[4] {
                groupFive.append(forecast)
            } else {
                groupSix.append(forecast)
            }
        }
        print("Group 1: \(groupOne.count)")
        print("Group 2: \(groupTwo.count)")
        print("Group 3: \(groupThree.count)")
        print("Group 4: \(groupFour.count)")
        print("Group 5: \(groupFive.count)")
        print("Group 6: \(groupSix.count)")

        forecastGroup.append(groupOne)
        print(forecastGroup[0].count)
        forecastGroup.append(groupTwo)
        print(forecastGroup[1].count)
        forecastGroup.append(groupThree)
        print(forecastGroup[2].count)
        forecastGroup.append(groupFour)
        print(forecastGroup[3].count)
        forecastGroup.append(groupFive)
        print(forecastGroup[4].count)
        forecastGroup.append(groupSix)
        print(forecastGroup[5].count)
        
        return forecastGroup
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
        DispatchQueue.main.async {
            self.showSearchBar()
            self.view.removeBluerLoader()
            self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Please enter a valid city name!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            self.searchTextField.becomeFirstResponder()
            self.searchTextField.shake()
            self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Error: Invalid City Name!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherWarningRed, NSAttributedString.Key.font : WeatherfulFonts.captionMedium!])
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { Timer in
                self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Look up weather by city name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherfulPlaceholderGrey, NSAttributedString.Key.font : WeatherfulFonts.captionMedium!])
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension MainVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didRequestHomeLocation = true
        if let latestLocation = locations.last {
            let latitude = latestLocation.coordinate.latitude
            let longitude = latestLocation.coordinate.longitude
            locationManager.stopUpdatingLocation() //FOLLOWUP
            weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            location.placemark { placemark, error in
                guard let placemark = placemark else {
                    print("Error:", error ?? "nil")
                    return
                }
                if let cityName = placemark.city {
                    self.homeCity = cityName
                }
            }
            
            weatherManager.fetchForecast(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    private func convertGeoCoord(lat: Double, lon: Double) -> (city: String, country: String) {
        var city = "hi"
        var country = "di"
        let location = CLLocation(latitude: lat, longitude: lon)
        location.placemark { placemark, error in
            guard let placemark = placemark else {
                print("Error:", error ?? "nil")
                return
            }
            if let cityName = placemark.city, let countryName = placemark.county {
                city = cityName
                country = countryName
            }
        }
        return (city, country)
    }
}

// MARK: - UICollectionViewDataSource

extension MainVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dateCollectionView {
            return forecastDateArray.count
        } else {
            if forecastGroup.count != 0 {
                return forecastGroup[selectedForcastGroup].count
            } else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == dateCollectionView {
            let cell = dateCollectionView.dequeueReusableCell(withReuseIdentifier: K.dateCellIdentifier, for: indexPath) as! DateCell
            //            if indexPath.row == 0 {
            //            dateCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .right)
            //            cell.isSelected = true
            
            //            if indexPath.row == 0 {
            //                cell.isSelected = true
            //                dateCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .right)
            //            }
            
            
            cell.dateLabel.text = forecastDateArray[indexPath.row]
            
            
//            if indexPath.row == 0 {
//                dateCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .right) //Add this line
//                cell.isSelected = true
//                if let titmeSmallBoldFont = WeatherfulFonts.titleSmallBold {
//                    cell.dateLabel.configure(font: titmeSmallBoldFont, color: .weatherfulWhite)
//                }
//            }
            
            
            // MARK: - Replace day of the week with "Today"
//            let currentDate = formatDate(timestamp: Date().description)
//            print(forecastDateArray.count)
//            print("currentdate: " + currentDate)
//            print(forecastArray[0])
//            if currentDate == forecastDateArray[0] {
//                var todayDate = currentDate
//                let start = todayDate.startIndex
//                let end = todayDate.index(todayDate.startIndex, offsetBy: 3)
//                let result = todayDate.replacingCharacters(in: start..<end, with: "Today")
                
//                cell.dateLabel.text = result
//                print(result)
//                cell.dateLabel.text?.replaceSubrange(0...2, with: "Today")
//            }
            
//            let letters = "zzzy"
//            // Replace first three characters with a string.
//            let start = letters.startIndex;
//            let end = letters.index(letters.startIndex, offsetBy: 3);
//            let result = letters.replacingCharacters(in: start..<end, with: "wh")
//            // The result.
//            print(result)
            
            
            return cell
            
        } else {
            let cell = forecastCollectionView.dequeueReusableCell(withReuseIdentifier: K.forecastCellIdentifier, for: indexPath) as! ForecastCell
            
            if forecastGroup.count != 0 {
                cell.timeLabel.text = forecastGroup[selectedForcastGroup][indexPath.row].timeString
                cell.conditionImageView.image = UIImage(named: forecastGroup[selectedForcastGroup][indexPath.row].staticConditionName)
                cell.tempLabel.text = forecastGroup[selectedForcastGroup][indexPath.row].tempString
            }
            return cell
        }
    }
    
    func formatDate(timestamp: String) -> String {
        
        var formattedString = String(Array(timestamp)[5...9]).replacingOccurrences(of: "-", with: "/")
        if formattedString[0] == "0" {
            formattedString = formattedString.replace("", at: 0)
            if formattedString[2] == "0" {
                formattedString = formattedString.replace("", at: 2)
            }
        } else if formattedString[3] == "0" {
            formattedString = formattedString.replace("", at: 3)
        }
        return formattedString
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
//    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension MainVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == dateCollectionView {
            return CGSize(width: 100, height: 40)
        } else {
            return CGSize(width: 100, height: 160)
        }
    }
}



// MARK: - UICollectionViewDelegate

extension MainVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dateCollectionView {
            guard let titleSmallBoldFont = WeatherfulFonts.titleSmallBold else { return }
            let selectedCell = collectionView.cellForItem(at: indexPath) as! DateCell
            selectedCell.dateLabel.configure(font: titleSmallBoldFont, color: .weatherfulWhite)
            selectedForcastGroup = indexPath.row
            print("selectedIndexPath: \(selectedForcastGroup)")
            forecastCollectionView.reloadData()
            forecastCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .right)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == dateCollectionView {
            guard let titleSmallFont = WeatherfulFonts.titleSmall else { return }
            let deselectedCell = collectionView.cellForItem(at: indexPath) as! DateCell
            deselectedCell.dateLabel.configure(font: titleSmallFont, color: .weatherfulLightGrey)
        }
    }
}

// MARK: - Others

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
    var county: String? { subAdministrativeArea }
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
