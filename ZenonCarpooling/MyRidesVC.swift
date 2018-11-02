//
//  MyRidesVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 6/12/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import Localize_Swift

class MyRidesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FirebaseManagerDelegate {
    
    // MARK: Properties
    
    let dbRef = Database.database().reference()
    var offeredRides = [Ride]()
    var requestedRides = [Ride]()
    var firebaseManager = FirebaseManager()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var offeredRidesRequestedRidesSegmentedControl: UISegmentedControl!
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager.delegate = self
        SVProgressHUD.setDefaultMaskType(.black)
        tableView.isHidden = true
        tableView.register(UINib(nibName: "RideTableCell", bundle: nil), forCellReuseIdentifier: "RideTableCell")
        offeredRidesRequestedRidesSegmentedControl.setTitle("Offered Rides", forSegmentAt: 0)
        offeredRidesRequestedRidesSegmentedControl.setTitle("Requested Rides", forSegmentAt: 1)
        offeredRidesRequestedRidesSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        offeredRidesRequestedRidesSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .touchUpInside)
        
        SVProgressHUD.setDefaultStyle(.dark)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUIOnLanguaheChange), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        
        fetchOfferedRides()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "My Rides".localized()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.selectedViewController = self
    }
    
    // MARK: -  UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if offeredRidesRequestedRidesSegmentedControl.selectedSegmentIndex == 0 {
            return offeredRides.count
        } else {
            return requestedRides.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedMode = offeredRidesRequestedRidesSegmentedControl.selectedSegmentIndex
        if(selectedMode == 0) {
            let ride = offeredRides[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "RideTableCell") as! RideTableCell
            
            cell.rideFromLabel.text = "\(ride.fromNeigborhood) - \(ride.fromCity)"
            cell.rideToLabel.text = "\(ride.toNeigborhood) - \(ride.toCity)"
            cell.rideDateAndTimeLabel.text = "\(ride.dateAndTime!.getLocalizedDateTimeString()!)"
            
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: -  UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    // MARK: - FirebaseManager delegate methods
    
    func didFinishFetchingOfferedRides(offeredRides: [Ride]) {
        self.offeredRides = offeredRides
        updateView()
        if(SVProgressHUD.isVisible()) {
            SVProgressHUD.dismiss()
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchOfferedRides() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Failed at fetching offered rides")
            return
        }
        let offeredRidesRef = dbRef.child("users").child(uid).child("offeredRides")
        offeredRidesRef.observe(.childAdded) { (snapshot) in
            if let rideInfo = snapshot.value as? JSONDictionary {
                let rideId = rideInfo["rideId"] as! String
                FirebaseManager.fetchRideInformation(forRide: rideId, completion: { (ride) in
                    if let ride = ride {
                        self.offeredRides.append(ride)
                        self.offeredRides.sort(by: { (ride1, ride2) -> Bool in
                            ride1.dateAndTime!.timeIntervalSince1970 > ride2.dateAndTime!.timeIntervalSince1970
                        })
                        self.tableView.insertRows(at: [IndexPath(row: self.offeredRides.count-1, section: 0)], with: UITableView.RowAnimation.automatic)
                        self.updateView()
                    }
                })
            }
        }
    }
    
    private func updateView() {
        let hasRides = offeredRides.count > 0 || requestedRides.count > 0
        tableView.isHidden = !hasRides
        if hasRides {
            tableView.reloadData()
        }
    }
    
    // MARK: - Handlers and Actions
    
    @objc func updateUIOnLanguaheChange() {
        tableView.reloadData()
    }
    
    @objc func reloadTable(notification: Notification) {
        DispatchQueue.main.async {
            SVProgressHUD.show()
            self.offeredRides.removeAll()
            self.updateView()
        }
    }
    
    @objc func segmentedControlValueChanged() {
        tableView.reloadData()
    }
    
}
