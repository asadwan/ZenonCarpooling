//
//  FirebaseManager.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 10/1/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import Foundation
import Firebase


let dbRef = Database.database().reference()


protocol FirebaseManagerDelegate {
    
    func didFinishFetchingOfferedRides(offeredRides: [Ride])
    func didFinishFetchingAllRides(allRides: [Ride])
    //func didFinishAddingNewRide(newRide: Ride)
    
}

// Workaround to optional protocol methods
extension FirebaseManagerDelegate {
    func didFinishFetchingOfferedRides(offeredRides: [Ride]) {}
    func didFinishFetchingAllRides(allRides: [Ride]) {}
}

class FirebaseManager {
    
    var delegate: FirebaseManagerDelegate?
    
    class func fetchRideInformation(forRide rideId: String, completion: @escaping (Ride?) -> Void) {
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
    
    func fetchAllRides() {
        let ridesRef = dbRef.child("rides")
        ridesRef.observeSingleEvent(of: .value) { (snapshot) in
            var rides = [Ride]()
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                if let rideJson = childSnapshot.value as? JSONDictionary {
                    let rideId = childSnapshot.key
                    let ride = Ride.createRideObjectWith(rideInfo: rideJson, rideId: rideId)
                    rides.append(ride)
                }
            }
            self.delegate?.didFinishFetchingAllRides(allRides: rides)
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
                    FirebaseManager.fetchRideInformation(forRide: rideId, completion: { (ride) in
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
    
    static func addNewRide(ride: Ride) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        ride.posterId = uid
        let posterId = uid
        let rideId = NSUUID().uuidString
        ride.rideId = rideId
        let ridesListRef = dbRef.child("rides")
        let currentUserRef = dbRef.child("users").child(posterId)
        let newRideRef = ridesListRef.child(rideId)
        newRideRef.updateChildValues(Ride.toRideJson(ride: ride))
        currentUserRef.child("offeredRides").childByAutoId().updateChildValues(["rideId": rideId])
    }
}


