//
//  FirebaseManager.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 10/1/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import Foundation
import Firebase


protocol FirebaseManagerDelegate {
    func didFinishFetchingOfferedRides(offeredRides: [Ride])
    
}

class FirebaseManager {
    
    var delegate: FirebaseManagerDelegate?
    
    func fetchRideInformation(forRide rideId: String, completion: @escaping (Ride?) -> Void) {
        let rideRef = dbRef.child("rides").child(rideId)
        rideRef.observeSingleEvent(of: .value) { (snapshot) in
            if let rideInfo = snapshot.value as? JSONDictionary {
                let ride = Ride.createRideObjectWith(rideInfo: rideInfo, rideId: rideId)
                completion(ride)
            } else {
                completion(nil)
                print("Error Fetching ride: \(rideId) information")
            }
        }
    }
    
    func fetchOfferedRides() {
        var rides = [Ride]()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Failed at fetching offered rides")
            return
        }
        let offeredRidesRef = dbRef.child("users").child(uid).child("offeredRides")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        offeredRidesRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let rideInfo = snap.value as? JSONDictionary {
                    let rideId = rideInfo["rideId"] as! String
                    dispatchGroup.enter()
                    self.fetchRideInformation(forRide: rideId, completion: { (ride) in
                        if let ride = ride {
                            rides.append(ride)
                        }
                        dispatchGroup.leave()
                    })
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.delegate?.didFinishFetchingOfferedRides(offeredRides: rides)
        }
    }
    
}


