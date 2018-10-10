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

class MyRidesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FirebaseManagerDelegate {
    
    // MARK: Properties
    
    let dbRef = Database.database().reference()
    var offeredRides = [Ride]()
    var requestedRides = [Ride]()
    var firebaseManager = FirebaseManager()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let refreshControl = UIRefreshControl()
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
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshOfferedRides(_:)), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        offeredRides = []
        SVProgressHUD.show()
        firebaseManager.fetchOfferedRides()
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
            cell.rideFromLabel.text = "\(ride.leavingFromNeighborhood!) - \(ride.leavingFromCity!)"
            cell.rideToLabel.text = "\(ride.goingToNeighborhood!) - \(ride.goingToCity!)"
            cell.rideDateandTimeLabel.text = "\(ride.outboundRideDateAndTime.getDateTimeString()!)"
            //cell.ride = offeredRides[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: -  UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - FirebaseManager delegate methods
    
    func didFinishFetchingOfferedRides(offeredRides: [Ride]) {
        self.offeredRides = offeredRides
        updateView()
        if(SVProgressHUD.isVisible()) {
            SVProgressHUD.dismiss()
        }
        if(refreshControl.isRefreshing) {
            refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Private Methods
    
    private func updateView() {
        let hasRides = offeredRides.count > 0 || requestedRides.count > 0
        tableView.isHidden = !hasRides
        if hasRides {
            tableView.reloadData()
        }
    }
    
    // MARK: - Handlers and Actions
    
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
    
    @objc func refreshOfferedRides(_ sender: Any) {
        firebaseManager.fetchOfferedRides()
    }
    
}
