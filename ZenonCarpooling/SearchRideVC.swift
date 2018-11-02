//
//  SearchRideVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/28/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class SearchRideVC: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, FirebaseManagerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: GMSMapView!
    var markers: [GMSMarker]!
    var rides: [Ride]?

    var locationManager = CLLocationManager()
    var firebaseManager = FirebaseManager()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        firebaseManager.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        firebaseManager.fetchAllRides()
        setUpMapView()
        
        tabBarController?.navigationItem.title = "Find a Ride".localized()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.navigationItem.title = "Find a Ride".localized()
        if Auth.auth().currentUser?.uid == nil {
            handleSignOut()
        }
    }
    
    // MARK: Private Methods
    
    fileprivate func setUpMapView() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        mapView.delegate = self
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
    }
    
    private func setUpMapMarkers() {
        if let rides = rides {
            for ride in rides {
                setUpRideMarker(ride: ride)
            }
        }
    }
    
    private func setUpRideMarker(ride: Ride) {
        if let longitude = ride.fromLongitude, let latitude = ride.fromLatitude {
            let marker = GMSMarker()
            marker.icon = UIImage(named: "ride_marker")
            marker.userData = ride
            marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            marker.map = self.mapView
        }
    }
    
    private func handleSignOut() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
            return
        }
        
        let loginScreen = LoginScreenVC(nibName: "LoginScreenVC", bundle: nil)
        present(loginScreen, animated: true, completion: nil)
    }

    
    // MARK: - Actions & Handlers
    
    @objc func dismissKeyboard() {
        searchBar.endEditing(true)
        view.endEditing(true)
    }
    
    @IBAction func viewTapGestureTapped(_ sender: Any) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    // MARK: - LocationManager delagate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.animate(toLocation: locations.last!.coordinate)
        mapView.animate(toZoom: mapView.maxZoom*0.8)
        manager.stopUpdatingLocation()
    }
    
    // MARK: - Firebase Manager delegate methods
    
    func didFinishFetchingAllRides(allRides: [Ride]) {
        self.rides = allRides
        setUpMapMarkers()
    }
}

extension SearchRideVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = RideMapMarkerView.instanceFromNib() as! RideMapMarkerView
        let ride = marker.userData as! Ride
        marker.tracksInfoWindowChanges = true
        infoWindow.fromLocationLabel.text = "\(ride.fromNeigborhood) - \(ride.fromCity)"
        infoWindow.toLocationLabel.text = "\(ride.toNeigborhood) - \(ride.toCity)"
        infoWindow.dateLabel.text = ride.dateAndTime?.getDateString()
        infoWindow.dayLabel.text = ride.dateAndTime?.dayOfWeek()
        infoWindow.timeLabel.text = ride.dateAndTime?.getTimeString()
        return infoWindow
    }
}
