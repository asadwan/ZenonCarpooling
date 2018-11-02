//
//  Ride.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 6/5/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import Foundation
import Firebase
import Localize_Swift
typealias JSONDictionary = [String:Any]

class Ride {
    
    private var observer: NSObjectProtocol!
    
    var rideId: String?
    var leavingFromCity: String?
    var leavingFromNeighborhood: String?
    var fromLatitude: Double?
    var fromLongitude: Double?
    var goingToCity: String?
    var goingToNeighborhood: String?
    var toLatitude: Double?
    var toLongitude: Double?
    var dateAndTime: Date?
    var offeredSeats: Int?
    var availableSeats: Int?
    var pricePerSeat: Float?
    var maxWaitingTime: Int?
    var ridersIds: [String] = [String]()
    var posterId: String?
    
    
    var toCity = ""
    var toNeigborhood = ""
    var fromCity = ""
    var fromNeigborhood = ""
    
    
    public static func createRideObjectWith(rideInfo: JSONDictionary, rideId: String) -> Ride {
        let ride = Ride()
        
        ride.rideId = rideId
        ride.leavingFromCity = rideInfo["fromCity"] as? String
        ride.leavingFromNeighborhood = rideInfo["fromNeighborhood"] as? String
        ride.goingToCity = rideInfo["toCity"] as? String
        ride.goingToNeighborhood = rideInfo["toNeighborhood"] as? String
        ride.dateAndTime  = Date.getDate(dateString: rideInfo["dateAndTime"] as! String)!
        ride.offeredSeats = rideInfo["offeredSeats"] as? Int
        ride.availableSeats = rideInfo["availableSeats"] as? Int
        ride.maxWaitingTime = rideInfo["maxWaitingTime"] as? Int
        ride.pricePerSeat = rideInfo["pricePerSeat"] as? Float
        ride.posterId = rideInfo["posterId"] as? String
        ride.fromLatitude = rideInfo["fromLatitude"] as? Double
        ride.fromLongitude = rideInfo["fromLongitude"] as? Double
        ride.toLongitude = rideInfo["toLongitude"] as? Double
        ride.toLatitude = rideInfo["toLatitude"] as? Double
        
        ride.getGoingToCity()
        ride.getGoingToNeighborhood()
        ride.getLeavingFromCity()
        ride.getLeavingFromNeighborhood()
        
//        ride.observer = NotificationCenter.default.addObserver(forName: Notification.Name(LCLLanguageChangeNotification), object: nil, queue: .main, using: { (notification) in
//            ride.getGoingToCity()
//            ride.getGoingToNeighborhood()
//            ride.getLeavingFromCity()
//            ride.getLeavingFromNeighborhood()
//        })
        
        return ride
    }
    
    public static func toRideJson(ride: Ride) -> JSONDictionary {
        var rideJson = JSONDictionary()
        
        rideJson["rideId"] = ride.rideId
        rideJson["posterId"] = ride.posterId
        rideJson["fromCity"] = ride.leavingFromCity
        rideJson["fromNeighborhood"] = ride.leavingFromNeighborhood
        rideJson["fromLongitude"] = ride.fromLongitude
        rideJson["fromLatitude"] = ride.fromLatitude
        rideJson["toCity"] = ride.goingToCity
        rideJson["toNeighborhood"] = ride.goingToNeighborhood
        rideJson["toLongitude"] = ride.toLongitude
        rideJson["toLatitude"] = ride.toLatitude
        rideJson["dateAndTime"] = ride.dateAndTime?.getDateTimeString()
        rideJson["offeredSeats"] = ride.offeredSeats
        rideJson["availableSeats"] = ride.availableSeats
        rideJson["maxWaitingTime"] = ride.maxWaitingTime
        rideJson["pricePerSeat"] = ride.pricePerSeat
        rideJson["ridersIds"] = []
        
        return rideJson
    }
    
    public func getLeavingFromNeighborhood() {
        let neigborhoodRef = Database.database().reference().child("locations").child(leavingFromCity!).child("neighborhoods").child(leavingFromNeighborhood!)
        neigborhoodRef.observeSingleEvent(of: .value) { (snapshot) in
            if let neighborhoodInfo = snapshot.value as? JSONDictionary {
                if(Localize.currentLanguage() == "ar") {
                    self.fromNeigborhood = neighborhoodInfo["arabicName"] as! String
                } else {
                    self.fromNeigborhood = neighborhoodInfo["englishName"] as! String
                }
            }
        }
    }
    
    public func getLeavingFromCity() {
        let cityRef = Database.database().reference().child("locations").child(leavingFromCity!)
        cityRef.observeSingleEvent(of: .value) { (snapshot) in
            if let cityInfo = snapshot.value as? JSONDictionary {
                if(Localize.currentLanguage() == "ar") {
                    self.fromCity = cityInfo["arabicName"] as! String
                } else {
                    self.fromCity = cityInfo["englishName"] as! String
                }
            }
        }
    }
    
    public func getGoingToNeighborhood() {
        let neigborhoodRef = Database.database().reference().child("locations").child(goingToCity!).child("neighborhoods").child(goingToNeighborhood!)
        neigborhoodRef.observeSingleEvent(of: .value) { (snapshot) in
            if let neighborhoodInfo = snapshot.value as? JSONDictionary {
                if(Localize.currentLanguage() == "ar") {
                    self.toNeigborhood = neighborhoodInfo["arabicName"] as! String
                } else {
                    self.toNeigborhood = neighborhoodInfo["englishName"] as! String
                }
            }
        }
    }
    
    public func getGoingToCity() {
        let cityRef = Database.database().reference().child("locations").child(goingToCity!)
        cityRef.observeSingleEvent(of: .value) { (snapshot) in
            if let cityInfo = snapshot.value as? JSONDictionary {
                if(Localize.currentLanguage() == "ar") {
                    self.toCity = cityInfo["arabicName"] as! String
                } else {
                    self.toCity = cityInfo["englishName"] as! String
                }
            }
        }
    }
}
