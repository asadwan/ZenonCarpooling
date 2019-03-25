//
//  CustumSearchVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 11/11/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import Material
import Firebase

protocol RideSearchVCDelegate {
    func didFinishSearching(rides results : [Ride])
}

class CustomSearchVC: UIViewController {
    
    
    // - MARK: Properties
    
    @IBOutlet weak var cancelButton: RaisedButton!
    @IBOutlet weak var originLocationLabel: UILabel!
    @IBOutlet weak var destinationLocationLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var searchButton: RaisedButton!
    
    var originLocationSelected = false
    var destinationLocationSelected = false
    
    var rideDate: Date!
    
    var originCityFBKey: String!
    var originNeigborhoodFBKey: String!
    
    var destinationCityFBKey: String!
    var destinationNeigborhoodFBKey: String!
    
    var delegate: RideSearchVCDelegate?
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRecognizersToLabels()
    }

    // - MARK: private methods
    
    private func addGestureRecognizersToLabels() {
        originLocationLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectOriginLocation)))
        destinationLocationLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDestinationLocation)))
        dateAndTimeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDateAndtime)))
        
    }
    
    private func isInputValid() -> Bool {
        return rideDate != nil && originCityFBKey != nil && originNeigborhoodFBKey != nil
        && destinationCityFBKey != nil && destinationNeigborhoodFBKey != nil
    }
    
    private func searchForRides() {
        if(!isInputValid()) { return }
        let ridesRef = dbRef.child("rides")
        ridesRef.queryOrdered(byChild: "fromNeighborhood").queryEqual(toValue: originCityFBKey)
        .observeSingleEvent(of: .value) { (snapshot) in
            var rides = [Ride]()
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                if let rideJson = childSnapshot.value as? JSONDictionary {
                    let rideId = childSnapshot.key
                    print(rideId)
                    let ride = Ride.createRideObjectWith(rideInfo: rideJson, rideId: rideId)
                    print(ride.fromCity)
                    rides.append(ride)
                }
                self.delegate?.didFinishSearching(rides: rides)
            }
        }
        dismiss(true)
    }

    // - MARK: Action and Handlers
    
    @objc func selectOriginLocation() {
        originLocationSelected = true
        let navController = UINavigationController()
        let locationPickerVC = PickLocationVC()
        navController.viewControllers = [locationPickerVC]
        locationPickerVC.delegate = self
        present(navController, animated: true, completion: nil)
    }
    
    @objc func selectDestinationLocation() {
        destinationLocationSelected = true
        let navController = UINavigationController()
        let locationPickerVC = PickLocationVC()
        navController.viewControllers = [locationPickerVC]
        locationPickerVC.delegate = self
        present(navController, animated: true, completion: nil)
    }
    
    @objc func selectDateAndtime() {
        let alert = UIAlertController(style: .actionSheet, title: "Select date and time".localized())
        alert.addDatePicker(mode: .dateAndTime, date: Date(), minimumDate: Date(timeIntervalSinceNow: 900), maximumDate: Date().addingTimeInterval(60 * 60 * 24 * 365)) { date in
            self.dateAndTimeLabel.text = date.getLocalizedDateTimeString()
            self.rideDate = date
        }
        alert.addAction(title: "Pick".localized(), style: .default)
        alert.show()
    }
    
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func search(_ sender: Any) {
        searchForRides()
    }
    
}

extension CustomSearchVC: PickLocationVCDelegate {
    func didFinishPickingLocation(location: Location) {
        if(originLocationSelected) {
            originLocationSelected = false
            originLocationLabel.text = "\(location.neighborhood) - \(location.city)".uppercased()
            originCityFBKey = location.cityFirDBKey
            originNeigborhoodFBKey = location.neighborhoodFirDBKey
        } else if (destinationLocationSelected) {
            destinationLocationSelected = false
            destinationCityFBKey = location.cityFirDBKey
            destinationNeigborhoodFBKey = location.neighborhoodFirDBKey
            destinationLocationLabel.text = "\(location.neighborhood) - \(location.city)".uppercased()
        }
    }
}
