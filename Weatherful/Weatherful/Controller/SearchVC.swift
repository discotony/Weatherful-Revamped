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
    let searchVC = UISearchController(searchResultsController: SearchResultVC())

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(x: 0,
                               y: view.safeAreaInsets.top,
                               width: view.frame.size.width,
                               height: view.frame.size.height - view.safeAreaInsets.top)
    }
    
    private func setUpUI() {
        navigationController?.isNavigationBarHidden = false
        title = "Look Up City"
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(mapView)
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        searchVC.hidesNavigationBarDuringPresentation = false
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dismiss",
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
//        print(searchController.searchBar.text)
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
    func didTapPlace(cityName: String, with coordinates: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true)
        
        // Remove all existing map pins
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        // Add a new map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates,
                                             span: MKCoordinateSpan(latitudeDelta: 2.0,
                                                                    longitudeDelta: 2.0)),
                          animated: true)
        
        // Pass coordinates to MainVC
        self.delegate?.didFetchCoordinates(cityName: cityName, with: coordinates)
        dismiss(animated: true)
    }
}
