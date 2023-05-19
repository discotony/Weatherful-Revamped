//
//  SearchResultVC.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/19/23.
//

import UIKit
import CoreLocation

protocol SearchResultVCDelegate: AnyObject {
    func didTapPlace(cityName: String, with coordinates: CLLocationCoordinate2D)
}

class SearchResultVC: UIViewController {
    
    weak var delegate: SearchResultVCDelegate?
    
    private let searchResultTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: K.searchResultCellIdentifier)
        return table
    }()
    
    private var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultTableView.frame = view.bounds
    }
    
    private func setUpUI() {
        view.backgroundColor = .clear
        view.addSubview(searchResultTableView)
    }
    
    private func setUpTableView() {
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
    }
    
    public func updateSearchResult(with places: [Place]) {
        searchResultTableView.isHidden = false
        self.places = places
        searchResultTableView.reloadData()
    }
}

extension SearchResultVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultTableView.dequeueReusableCell(withIdentifier: K.searchResultCellIdentifier, for: indexPath)
        let place = places[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = place.name
        cell.contentConfiguration = content
        return cell
    }
}

extension SearchResultVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(places[indexPath.row])
        tableView.isHidden = true
        
        let selectedPlace = places[indexPath.row]
        // FOLLOWUP
        GooglePlacesManager.shared.resolveLocation(for: selectedPlace) { [weak self] result in
            switch result {
            case .success(let coordinates):
                DispatchQueue.main.async {
                    print(selectedPlace.name)
                    self?.delegate?.didTapPlace(cityName: selectedPlace.formattedName, with: coordinates)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
