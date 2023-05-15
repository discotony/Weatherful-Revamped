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
    @IBOutlet weak var forecastHeaderLabel: UILabel!
    @IBOutlet weak var forecastDetailButton: UIButton!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    private var isSearchTriggered: Bool = true // FOLLOWUP
    private var tempUnits: [tempUnits] = [.metric, .imperial] // FOLLOWUP
    
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    var location: CLLocation?
    
    var conditionName = ""
    var homeLocation = ""
    var didRequestHomeLocation = true
    var forecastArray = [ForecastModel]()
    var forecastGroup = [[ForecastModel]]()
    var forecastDateArray = [String]()
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        resetPlaceholder()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        setUpHeaderCollectionView()
        
        view.showBlurLoader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        backgroundImageView.updateBackground() // FOLLOWUP
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        headerView.backgroundColor = .clear
        self.headerView.roundCorners()
        
        guard let titleLargeFont = WeatherfulFonts.titleLarge else { return }
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
    
    private func resetPlaceholder() {
        cityLabel.text = ""
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
    
    @IBAction func forecastDetailButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.showForecastIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.showForecastIdentifier {
            let destinationVC = segue.destination as! ForecastVC
            destinationVC.forecastArray = forecastArray
            destinationVC.forecastGroup = forecastGroup
            destinationVC.numForecastDates = forecastDateArray.count
            destinationVC.homeLocation = homeLocation
        }
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
            var currentLocation = ""
            let location = CLLocation(latitude: weather.coordinates.lat, longitude: weather.coordinates.lon)
            location.placemark { placemark, error in
                guard let placemark = placemark else {
                    print("Error:", error ?? "nil")
                    return
                }
                if var country = placemark.country {
                    if country == "United States" {
                        if let state = placemark.state {
                            country = state
                        } else {
                            country = "US"
                        }
                    }
                    currentLocation = weather.cityName + ", \(country)"
                    self.cityLabel.text = currentLocation
                    self.homeLocation = currentLocation
                }
            }
            
            self.weatherConditionLabel.text = weather.conditionDescription.capitalizeFirstLetters
            self.conditionName = weather.animatedConditionName
            self.updateConditionImage()
            self.currentTempLabel.text = (weather.tempCurrentString) //FOLLOWUP
            self.maxMinTempLabel.text = "H: \(weather.tempMaxString)  L: \(weather.tempMinString)"
            self.windLabel.text = weather.windString + " "
            self.humidityLabel.text = weather.humidityString
            
            self.resetLocationButton.isHidden = currentLocation == self.homeLocation ? true : false
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { Timer in
                self.view.removeBluerLoader()
            }
        }
    }
    
    func didUpdateForecast(_ weatherManager: WeatherManager, forecast: [ForecastModel]) {
        DispatchQueue.main.async {
            self.forecastArray = forecast
            self.forecastDateArray = self.getDateGroup(forecastArray: forecast)
            self.forecastGroup = self.groupForecast(forecastArray: forecast)
            self.forecastCollectionView.reloadData()
        }
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
            weatherManager.fetchForecast(latitude: latitude, longitude: longitude)
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
            cell.configure(date: forecast.dateShort, time: forecast.time, imageName: forecast.conditionImageName, temp: forecast.tempString)
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
