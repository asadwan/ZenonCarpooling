//
//  User.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/18/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ZenonUser: NSObject {
    
    var firstName: String
    var lastName: String
    var mobileNumber: Int?
    var email: String
    var birthDate: Date?
    var profileImage: UIImage!
    var id: String?
    
    init(firstName: String, lastName: String, mobileNumber: Int, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.mobileNumber = mobileNumber
        self.email = email
    }
    
    init(firstName: String, lastName: String, profileImage: UIImage, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.profileImage = profileImage
        self.email = email
    }
    
    class func info(forUserID: String, completion: @escaping (ZenonUser) -> Swift.Void) {
        Database.database().reference().child("users").child(forUserID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let firstName = data["firstName"] as! String
                let lastName = data["lastName"] as! String
                let email = data["email"] as! String
                let link = URL.init(string: data["profilePicLink"] as! String)
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profilePic = UIImage.init(data: data!)
                        let user = ZenonUser(firstName: firstName, lastName: lastName, profileImage: profilePic!, email: email)
                        user.id = forUserID
                        completion(user)
                    }
                }).resume()
            }
        })
    }
    
    class func downloadAllUsers(exceptID: String, completion: @escaping (ZenonUser) -> Void) {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            let data = snapshot.value as! [String: Any]
            let credentials = data["credentials"] as! [String: String]
            if id != exceptID {
                let firstname = credentials["name"]!
                let email = credentials["email"]!
                let link = URL.init(string: credentials["profilePicLink"]!)
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profilePic = UIImage.init(data: data!)
//                        let user = ZenonUser.init(name: name, email: email, id: id, profilePic: profilePic!)
//                        completion(user)
                    }
                }).resume()
            }
        })
    }
    
    class func checkUserVerification(completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().currentUser?.reload(completion: { (_) in
            let status = (Auth.auth().currentUser?.isEmailVerified)!
            completion(status)
        })
    }
}
