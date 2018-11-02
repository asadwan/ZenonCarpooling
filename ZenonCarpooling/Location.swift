//
//  Location.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 10/30/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import Foundation
import CoreLocation

class Location {
    
    var city: String
    var neighborhood: String
    var cityFirDBKey: String
    var neighborhoodFirDBKey: String
    var coordinates: CLLocationCoordinate2D
    
    init(city: String, neighborhood: String, coordinates: CLLocationCoordinate2D,
         neighborhoodFirDBKey: String, cityFirDBKey: String) {
        self.city = city
        self.neighborhood = neighborhood
        self.coordinates = coordinates
        self.cityFirDBKey = cityFirDBKey
        self.neighborhoodFirDBKey = neighborhoodFirDBKey
    }
}
