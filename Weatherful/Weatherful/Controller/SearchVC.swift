//
//  SearchVC.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/18/23.
//

import UIKit
import MapKit

protocol SearchVCDelegate: AnyObject {
    func didFetchCoordinates(cityName: String, with coordinates: CLLocationCoordinate2D)
}

class SearchVC: UIViewController {
    
    weak var delegate: SearchVCDelegate?
    
    let mapView = MKMapView()
    let searchButton = UIButton()
    let searchVC = UISearchController(searchResultsController: SearchResultVC())
    
    var selectedPlace: Place?
    var coordinates: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        searchButton.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(x: 0,
                               y: view.safeAreaInsets.top,
                               width: view.frame.size.width,
                               height: view.frame.size.height - view.safeAreaInsets.top)
        mapView.addSubview(searchButton)
        setUpSearchButton()
    }
    
    private func setUpSearchButton() {
        guard let titleSmallFont = WeatherfulFonts.titleSmall else { return }
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        let searchButtonTitle = NSAttributedString(string: "Look Up Weather", attributes: [NSAttributedString.Key.font : titleSmallFont, NSAttributedString.Key.foregroundColor : UIColor.weatherfulWhite])
        searchButton.setAttributedTitle(searchButtonTitle, for: .normal)
        searchButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        searchButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        searchButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -64).isActive = true
        searchButton.backgroundColor = .weatherfulBlack.withAlphaComponent(0.5)
        searchButton.roundCorners(cornerRadius: searchButton.frame.height / 2)
        searchButton.applyDarkShadow()
        searchButton.addTarget(self, action: #selector(SearchButtonPressed), for: .touchUpInside)
    }
    
    @objc func SearchButtonPressed(sender: UIButton) {
        guard let selectedPlace = self.selectedPlace, let coordinates = self.coordinates else { return }
        self.delegate?.didFetchCoordinates(cityName: selectedPlace.formattedName, with: coordinates)
        dismiss(animated: true)
    }
    
    private func setUpUI() {
        navigationController?.isNavigationBarHidden = false
        title = "Look Up City"
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.backgroundColor = .systemBackground
        searchVC.hidesNavigationBarDuringPresentation = false
        searchVC.automaticallyShowsCancelButton = false
        navigationItem.searchController = searchVC
        
        /*
        guard let titleMediumFont = WeatherfulFonts.titleMedium else { return }
        let dismissButton = UIButton()
//        let dismissButtonAttachment = NSTextAttachment()
//        dismissButtonAttachment.image = UIImage(named: "icon_left_arrow")
//        dismissButtonAttachment.setImageHeight(font: titleMediumFont, height: 14)
        let dismissButtonTitle = NSMutableAttributedString(string: "Dismiss", attributes: [NSAttributedString.Key.foregroundColor : UIColor.weatherfulWhite])
//        dismissButtonTitle.insert(NSAttributedString(attachment: dismissButtonAttachment), at: 0)
        dismissButton.setAttributedTitle(dismissButtonTitle, for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        */
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(dismissButtonPressed))
    }
    
    @objc func dismissButtonPressed(sender: UIButton) {
        guard let navigationController = self.navigationController else { return }
        navigationController.dismiss(animated: true)
    }
}

extension SearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let searchResultVC = searchController.searchResultsController as? SearchResultVC else { return }
        searchResultVC.delegate = self
        
//        GooglePlacesManager.shared.findPlaces(query: <#T##String#>, completion: <#T##(Result<[Place], Error>) -> Void#>) // FOLLOWUP
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    searchResultVC.updateSearchResult(with: places)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SearchVC: SearchResultVCDelegate {
    func didTapPlace(selectedPlace: Place) {
        self.searchButton.isHidden = false
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true)
        
        
        // Remove all existing map pins
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        // Fetch coordinates and add a new pin
        GooglePlacesManager.shared.resolveLocation(for: selectedPlace) { result in
            switch result {
            case .success(let coordinates):
                DispatchQueue.main.async {
                    print(selectedPlace.name)
                    
                    // Add a new map pin
                    let pin = MKPointAnnotation()
                    pin.coordinate = coordinates
                    
                    self.mapView.addAnnotation(pin)
                    self.mapView.setRegion(MKCoordinateRegion(center: coordinates,
                                                         span: MKCoordinateSpan(latitudeDelta: 1.0,
                                                                                longitudeDelta: 1.0)),
                                      animated: true)
                    
                    self.selectedPlace = selectedPlace
                    self.coordinates = coordinates
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
