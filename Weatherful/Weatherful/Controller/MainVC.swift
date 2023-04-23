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
    @IBOutlet weak var maxMinTempLabel: UILabel!
    
    @IBOutlet weak var additionalWeatherStackView: UIStackView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    private var isSearchTriggered: Bool = true
    private var tempUnits: [tempUnits] = [.metric, .imperial]
    
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setUpAppIcon()
        setUpUI()
        setUpPlaceholder()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
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
        
        headerView.backgroundColor = .clear
        self.headerView.roundCorners()
        guard let titleLargeFont = WeatherfulFonts.titmeLarge else { return }
        cityLabel.configure(font: titleLargeFont)
        searchTextField.backgroundColor = .clear
        searchTextField.textColor = .weatherfulDarkGrey
        searchTextField.tintColor = .weatherfulPlaceholderGrey
        searchTextField.borderStyle = .none
        searchTextField.font = WeatherfulFonts.captionMedium
        
        guard let titleXLFont = WeatherfulFonts.titleXL else { return }
        guard let captionLargeFont = WeatherfulFonts.captionLarge else { return }
        guard let captionMediumFont = WeatherfulFonts.captionMedium else { return }
        weatherConditionLabel.configure(font: captionLargeFont)
        currentTempLabel.configure(font: titleXLFont)
        maxMinTempLabel.configure(font: captionMediumFont)
        windLabel.configure(font: captionMediumFont)
        humidityLabel.configure(font: captionMediumFont)
    }
    
    private func setUpPlaceholder() {
        cityLabel.text = "San Francisco"
        weatherImageView.image = UIImage(named: "clear")
        weatherConditionLabel.text = "Heavy Snow"
        currentTempLabel.text = "72°F"
        maxMinTempLabel.text = "Wind: 15 km/h, Humidty: 43%"
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
            self.weatherImageView.image = UIImage(named: weather.conditionName)
            print(weather.conditionName)
            self.cityLabel.text = weather.cityName
            self.weatherConditionLabel.text = weather.conditionDescription.capitalizeFirstLetters
            self.currentTempLabel.text = "\(weather.tempCurrentString)°F" //FOLLOWUP
            self.maxMinTempLabel.text = "H: \(weather.tempMaxString)  L: \(weather.tempMinString)"
            self.windLabel.text = weather.windString + " "
            self.humidityLabel.text = weather.humidityString
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
