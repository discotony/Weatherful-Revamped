//
//  GooglePlacesManager.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/18/23.
//

import Foundation
import GooglePlaces
import CoreLocation

class GooglePlacesManager {
    
    static let shared = GooglePlacesManager() // shared instance use it as a singleton
    private let client = GMSPlacesClient.shared()
    let APIKey = "AIzaSyCgoSOoEno8Wp1s4CxJmv5w0VIIyQQpXV4"
    
    private init() {}
    
    enum GooglePlacesError: Error {
        case failedToFind
        case failedToGetCoorindates
    }
    
    public func findPlaces(query: String, completion: @escaping (Result<[Place], Error>) -> Void) {
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil){ results, error in
            guard let results = results, error == nil else {
                completion(.failure(GooglePlacesError.failedToFind))
                return
            }
            
            let places: [Place] = results.compactMap({
                Place(name: $0.attributedFullText.string, id: $0.placeID)
            })
            
            completion(.success(places))
        }
    }
    
    public func resolveLocation(for place: Place, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {

        client.fetchPlace(fromPlaceID: place.id,
                          placeFields: .coordinate,
                          sessionToken: nil) { googlePlace, error in
            guard let googlePlace = googlePlace, error == nil else {
                completion(.failure(GooglePlacesError.failedToGetCoorindates))
                return
            }
            
            let coordinates = CLLocationCoordinate2D(latitude: googlePlace.coordinate.latitude,
                                                     longitude: googlePlace.coordinate.longitude)
            completion(.success(coordinates))
        }
    }
}
