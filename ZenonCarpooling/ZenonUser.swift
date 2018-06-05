//
//  User.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/18/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import Foundation
import UIKit

class ZenonUser: NSObject {
    var firstName: String
    var lastName: String
    var mobileNumber: Int
    var email: String
    var profileImage: UIImage!
    
    init(firstName: String, lastName: String, mobileNumber: Int, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.mobileNumber = mobileNumber
        self.email = email
    }
    
    
}
