//
//  Ride.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 6/5/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import Foundation
import Firebase
typealias JSONDictionary = [String:Any]

class Ride: NSObject {
    
    var rideId: String!
    var leavingFromCity: String!
    var leavingFromNeighborhood: String!
    var goingToCity: String!
    var goingToNeighborhood: String!
    var inboundRideDateAndTime: Date?
    var outboundRideDateAndTime: Date!
    var isRoundTrip: Bool!
    var inboundRideNumberOfOfferedSeats: Int?
    var inboundRideAvailableSeats: Int?
    var outboundRideNumberOfOfferedSeats: Int!
    var outboundRideAvailableSeats: Int!
    var pricePerSeat: Float32!
    var maxWaitingTime: Int!
    var ridersIds: [String] = [String]()
    var posterId: String!
    
    override init() {
        super.init()
    }
    
    public static func createRideObjectWith(rideInfo: JSONDictionary, rideId: String) -> Ride {
        let ride = Ride()
        let isRoundTripString = rideInfo["isRoundTrip"] as! String
        let isRoundTrip = isRoundTripString == "Yes" ? true : false
        
        ride.rideId = rideId
        ride.leavingFromCity = rideInfo["leavingFromCity"] as? String
        ride.leavingFromNeighborhood = rideInfo["leavingFromNeighborhood"] as? String
        ride.goingToCity = rideInfo["goingToCity"] as? String
        ride.goingToNeighborhood = rideInfo["goingToNeighborhood"] as? String
        let outboundRideTime = rideInfo["outboundRideTime"] as? String
        let outboundRideWeekday = rideInfo["outboundRideWeekday"] as? String
        let outboundRideDate = rideInfo["outboundRideDate"] as? String
        ride.outboundRideDateAndTime  = Date.getDate(dateString: "\(outboundRideWeekday!), \(outboundRideTime!) \(outboundRideDate!)")!
        ride.outboundRideNumberOfOfferedSeats = rideInfo["outboundRideNumberOfOfferedSeats"] as? Int
        ride.outboundRideAvailableSeats = rideInfo["outboundRideAvailableSeats"] as? Int
        ride.maxWaitingTime = rideInfo["maxWaitingTime"] as? Int
        ride.pricePerSeat = rideInfo["pricePerSeat"] as? Float32
        ride.posterId = rideInfo["posterId"] as? String
        
        if !isRoundTrip {
            return ride
        }
        
        let inboundRideTime = (rideInfo["inboundRideTime"] as! String)
        let inboundRideWeekday = (rideInfo["inboundRideWeekday"] as! String)
        let inboundRideDate = (rideInfo["inboundRideDate"] as! String)
        ride.outboundRideDateAndTime  = Date.getDate(dateString: "\(inboundRideWeekday), \(inboundRideTime) \(inboundRideDate)")!
        ride.inboundRideNumberOfOfferedSeats = (rideInfo["inboundRideNumberOfOfferedSeats"] as! Int)
        ride.inboundRideAvailableSeats = (rideInfo["inboundRideAvailableSeats"] as! Int)
        
        return ride
    }
}
