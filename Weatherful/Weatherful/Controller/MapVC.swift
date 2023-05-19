//
//  MapVC.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/18/23.
//

import UIKit
import MapKit

class MapVC: UIViewController, UISearchResultsUpdating {
    
    let mapView = MKMapView()
    let searchVC = UISearchController(searchResultsController: MapResultVC())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Maps"
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(mapView)
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        navigationItem.searchController = searchVC
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.size.width,
            height: view.frame.size.height - view.safeAreaInsets.top
        )
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let mapResultVC = searchController.searchResultsController as? MapResultVC else {
            return
        }
        
        mapResultVC.delegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case.success(let places):
                DispatchQueue.main.async {
                    mapResultVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension MapVC: ResultViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true)
        // Remove all map pins
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        // Add a map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates,
                                             span: MKCoordinateSpan(latitudeDelta: 0.2,
                                                                    longitudeDelta: 0.2)),
                          animated: true)
    }
}
