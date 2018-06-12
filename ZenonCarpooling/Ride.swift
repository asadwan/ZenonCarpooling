//
//  Ride.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 6/5/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import Foundation

class Ride: NSObject {
    var rideID: String
    var leavingFrom: String
    var goingTo: String
    var inboundRideDateAndTime: Date?
    var outboundRideDateAndTime: Date
    var isRoundTrip: Bool
    var numberOfSeats: Int
    var numberOfAvailableSeats: Int
    var riders: [String] = [String]()
    
    
    
    init(rideID: String, leavingFrom: String, goingTo: String, inboundRideDateAndTime: Date?, outboundRideDateAndTime: Date, isRoundTrip: Bool, numberOfSeats: Int, numberOfAvailableSeats: Int) {
        if inboundRideDateAndTime != nil {
            self.inboundRideDateAndTime = inboundRideDateAndTime
        }
        
        self.rideID = rideID
        self.leavingFrom = leavingFrom
        self.goingTo = goingTo
        self.outboundRideDateAndTime = outboundRideDateAndTime
        self.isRoundTrip =  isRoundTrip
        self.numberOfSeats = numberOfSeats
        self.numberOfAvailableSeats = numberOfAvailableSeats
    }
}
