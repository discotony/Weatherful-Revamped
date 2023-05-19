//
//  MapResultVC.swift
//  Weatherful
//
//  Created by Antony Bluemel on 5/18/23.
//

import UIKit
import CoreLocation

protocol ResultViewControllerDelegate: AnyObject {
    func didTapPlace(with coordinates: CLLocationCoordinate2D)
}

class MapResultVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: ResultViewControllerDelegate? //FOLLOWUP
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    public func update(with places: [Place]) {
        self.tableView.isHidden = false
        self.places = places
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print(places[indexPath.row].name)
        tableView.isHidden = true
        
        let selectedPlace = places[indexPath.row]
        GooglePlacesManager.shared.resolveLocation(for: selectedPlace) { [weak self] result in
            switch result {
            case .success(let coorindates):
                DispatchQueue.main.async {
                    self?.delegate?.didTapPlace(with: coorindates) // FOLLOWUP
                }
            case .failure(let error):
                
                print(error)
            }
        }
        
    }
}
