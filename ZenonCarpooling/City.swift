//
//  City.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 11/2/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import Foundation

class City {
    
    var arabicName: String = ""
    var englishName: String
    var cityKey: String
    var neighborhoods = [Neighborhood]()
    
    init(arabicName: String, englishName: String, cityKey: String){
        self.arabicName = arabicName
        self.englishName = englishName
        self.cityKey = cityKey
    }
}
