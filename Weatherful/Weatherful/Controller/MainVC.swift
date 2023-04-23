//
//  ViewController.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import UIKit

class MainVC: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var dropdownSymbol: UIImageView!
    
    @IBOutlet weak var tappableView: UIView!
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var weatherDetailsLabel: UILabel!
    
    private var isSearchTriggered: Bool = true
    private var tempUnits: [tempUnits] = [.metric, .imperial]
    
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpPlaceholder()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
    }
    
    private func setUpUI() {
        
        headerView.backgroundColor = .clear
        self.headerView.roundCorners()
        guard let titleLargeFont = WeatherfulFonts.titmeLarge else { return }
        cityLabel.configure(font: titleLargeFont, color: .weatherfulBlack)
        searchTextField.backgroundColor = .clear
        searchTextField.textColor = .weatherfulDarkGrey
        searchTextField.tintColor = .weatherfulPlaceholderGrey
        searchTextField.borderStyle = .none
        searchTextField.font = WeatherfulFonts.captionMedium
        dropdownSymbol.tintColor = .weatherfulBlack
        
        guard let titleXLFont = WeatherfulFonts.titleXL else { return }
        guard let captionLargeFont = WeatherfulFonts.captionLarge else { return }
        guard let captionMediumFont = WeatherfulFonts.captionMedium else { return }
        weatherConditionLabel.configure(font: captionLargeFont, color: .weatherfulBlack)
        currentTempLabel.configure(font: titleXLFont, color: .weatherfulBlack)
        weatherDetailsLabel.configure(font: captionMediumFont, color: .weatherfulBlack)
    }
    
    private func setUpPlaceholder() {
        cityLabel.text = "San Francisco"
        weatherImageView.image = UIImage(systemName: "cloud_snow")
        weatherConditionLabel.text = "Heavy Snow"
        currentTempLabel.text = "72°F"
        weatherDetailsLabel.text = "Wind: 15 km/h, Humidty: 43%"
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
            self.headerView.backgroundColor = .weatherfulLightGrey.withAlphaComponent(0.5)
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
}

// MARK: - UITextFieldDelegate
extension MainVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn: " + searchTextField.text!)
        self.view.endEditing(true) //FOLLOWUP
        return true
        
    }
    
    // Input Validation
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Make sure to enter a city name!"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let cityName = searchTextField.text {
            let formattedCityName = String((cityName as NSString).replacingOccurrences(of: " ", with: "+"))
            print("textFieldDidEndEditing " + formattedCityName)
            weatherManager.fetchWeather(from: formattedCityName)
        }
        
        // Reset search field
        searchTextField.text = ""
        hideSearchBar()
    }
}

// MARK: - WeatherManagerDelegate

extension MainVC: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.weatherImageView.image = UIImage(named: "sun_max") // customize it
            self.weatherConditionLabel.text = weather.conditionDescription.capitalizeFirstLetters
            self.currentTempLabel.text = "\(weather.tempCurrentString)°F" //FOLLOWUP
    //        weatherDetailsLabel.text =
            
            
    //
    //        let windSymbol = NSTextAttachment(image: UIImage(systemName: "wind")!.withTintColor(.weatherfulBlack))
    //        let humiditySymbol = NSTextAttachment(image: UIImage(systemName: "humidity")!.withTintColor(.weatherfulBlack))
    //
    //
    //        let windString = NSAttributedString(string: " \(weather.wind)  ")
    //        let humidityString = NSAttributedString(string: " \(weather.humidity)")
    //
    //        let weatherDetails = NSMutableString()
    //
    //        windString.insert(NSAttributedString(attachment: windSymbol), at: 0)
    //
    //
    //        dailyWeatherHeaderLabel.configure(font: CustomFonts.captionMedium!)
    //        let headerTitle = NSMutableAttributedString(string: " 5-DAY FORECAST")
    //        headerTitle.insert(NSAttributedString(attachment: imageAttachment), at: 0)
    //        dailyWeatherHeaderLabel.attributedText = headerTitle
    //
    //
    //
    //
    //        let weatherDetailsString = NSAttributedString()
    //        weatherDetailsString.insert(NSAttributedString(attachment: imageAttachment), at: 0)
    //
    //        dailyWeatherHeaderLabel.configure(font: CustomFonts.captionMedium!)
    //        let headerTitle = NSMutableAttributedString(string: " 5-DAY FORECAST")
    //        headerTitle.insert(NSAttributedString(attachment: imageAttachment), at: 0)
    //        dailyWeatherHeaderLabel.attributedText = headerTitle
            
        }
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
        DispatchQueue.main.async {
            self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Please enter a valid city name!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
//            self.animateWarningShake()
            self.searchTextField.becomeFirstResponder()
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { Timer in
                self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Look up weather by city name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherfulPlaceholderGrey, NSAttributedString.Key.font : WeatherfulFonts.captionMedium!])
            }
        }
    }
    
//    private func animateWarningShake() {
//        let animation = CABasicAnimation(keyPath: "position")
//        animation.duration = 0.07
//        animation.repeatCount = 4
//        animation.autoreverses = true
//        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.searchButtonView.center.x - 5, y: self.searchButtonView.center.y))
//        animation.toValue = NSValue(cgPoint: CGPoint(x: self.searchButtonView.center.x + 5, y: self.searchButtonView.center.y))
//
//        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
//        self.searchButtonView.layer.add(animation, forKey: "position")
//    }
}
