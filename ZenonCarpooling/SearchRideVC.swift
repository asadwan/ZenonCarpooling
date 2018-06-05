//
//  SearchRideVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/28/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchRideVC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: GMSMapView!
    @IBAction func viewTapGestureTapped(_ sender: Any) {
        searchBar.resignFirstResponder()
    }
    var locationManager = CLLocationManager()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        mapView.delegate = self
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.navigationItem.title = "Find a ride"
    }
    

    
    // MARK: Actions & Handlers
    
    @objc func dismissKeyboard() {
        searchBar.endEditing(true)
        view.endEditing(true)
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
