//
//  PickLocationVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 10/29/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import Firebase
import Localize_Swift
import SVProgressHUD
import GooglePlacePicker
import GoogleMaps

protocol PickLocationVCDelegate {
    func didFinishPickingLocation(location: Location)
}

class PickLocationVC: UITableViewController, GMSPlacePickerViewControllerDelegate {
    
    
    
    // MARK: - Properites
    
    var cities = [City]()
    
    var delegate: PickLocationVCDelegate?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLocations()
        navigationItem.title = "Pick a neighboorhood".localized()
        navigationItem.hidesSearchBarWhenScrolling = true
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search locations"
        searchController.searchBar.tintColor = UIColor.white
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cities[section].nieghborhoods.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let neighborhood = cities[indexPath.section].nieghborhoods[indexPath.row]
      
        cell.textLabel?.text = Localize.currentLanguage() == "en" ? neighborhood.englishName : neighborhood.arabicName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Localize.currentLanguage() == "ar" ? cities[section].arabicName : cities[section].englishName
    }
    
    // MARK: - GMSPlacePickerViewControllerDelegate
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        let selectedRowIndexPath = tableView.indexPathForSelectedRow
        let city = cities[selectedRowIndexPath!.section]
        let neighborhood = cities[selectedRowIndexPath!.section].nieghborhoods[selectedRowIndexPath!.row]
        var cityName: String
        var neighborhoodName: String
        if(Localize.currentLanguage() == "ar") {
            cityName = city.arabicName
            neighborhoodName = neighborhood.arabicName
        } else {
            cityName = city.englishName
            neighborhoodName = neighborhood.englishName
        }
        
        let location = Location(city: cityName, neighborhood: neighborhoodName, coordinates: place.coordinate, neighborhoodFirDBKey: neighborhood.neighborhoodKey, cityFirDBKey: city.cityKey)
        navigationController?.dismiss(animated: true, completion: nil)
        delegate?.didFinishPickingLocation(location: location)
        
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNeighborhood = cities[indexPath.section].nieghborhoods[indexPath.row]
        let coordinates1 = CLLocationCoordinate2D(latitude: selectedNeighborhood.latitude + 0.007, longitude: selectedNeighborhood.longitude)
        let coordinates2 = CLLocationCoordinate2D(latitude: selectedNeighborhood.latitude - 0.007, longitude: selectedNeighborhood.longitude)
        let vp = GMSCoordinateBounds(coordinate: coordinates1, coordinate: coordinates2)
        let config = GMSPlacePickerConfig(viewport: vp)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        self.navigationController?.pushViewController(placePicker, animated: true)
    }
    
    // MARK: - Private methods
    
    private func fetchLocations() {
        SVProgressHUD.show()
        let locationsRef = Database.database().reference().child("locations")
        locationsRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                if let locationsInfo = childSnapshot.value as? JSONDictionary {
                    let cityKey = childSnapshot.key
                    let arabicName = locationsInfo["arabicName"] as! String
                    let englishName = locationsInfo["englishName"] as! String
                    let city = City(arabicName: arabicName, englishName: englishName, cityKey: cityKey)
                    if let neighborhoodsJson = locationsInfo["neighborhoods"] as? JSONDictionary {
                        for (neighborhoodKey, neighborhoodInfo) in neighborhoodsJson {
                            if let neighborhoodJson = neighborhoodInfo as? JSONDictionary{
                                let arabicName = neighborhoodJson["arabicName"] as! String
                                let englishName = neighborhoodJson["englishName"] as! String
                                let latitude = neighborhoodJson["latitude"] as! Double
                                let longitude = neighborhoodJson["longitude"] as! Double
                                let neighborhood = Neighborhood(neighborhoodKey: neighborhoodKey, arabicName: arabicName, englishName: englishName, longitude: longitude, latitude: latitude)
                                city.nieghborhoods.append(neighborhood)
                            }
                        }
                    }
                    self.cities.append(city)
                }
            }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.cities.forEach({ (city) in
                    city.nieghborhoods.sort(by: { (n1, n2) -> Bool in
                        n1.englishName < n2.englishName
                    })
                })
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK - Actions & Handlers
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
