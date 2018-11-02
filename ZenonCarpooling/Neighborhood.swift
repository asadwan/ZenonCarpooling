//
//  Neighborhood.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 10/29/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import Foundation

class Neighborhood {
    
    var arabicName: String
    var englishName: String
    var longitude: Double
    var latitude: Double
    var neighborhoodKey: String
    
    init(neighborhoodKey: String, arabicName: String, englishName: String, longitude: Double, latitude: Double) {
        self.neighborhoodKey = neighborhoodKey
        self.arabicName = arabicName
        self.englishName = englishName
        self.longitude = longitude
        self.latitude = latitude
    }
}
