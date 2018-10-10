//
//  ShowOrEditProfileVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/27/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import Firebase

class ShowOrEditProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomAlertViewDelegate {

    // MARK: - Properties

    @IBOutlet weak var tableView: UITableView!
    var hapticNotification = UINotificationFeedbackGenerator()
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lightGrey = UIColor(displayP3Red: 230/255.5, green: 230/255.5, blue: 230/255.5, alpha: 1.0)
        tableView.backgroundColor = lightGrey
        tableView.separatorColor = tableView.backgroundColor
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Profile"
        
        // Set up tableView 
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProfileImageTableCell", bundle: nil), forCellReuseIdentifier: "ProfileImageTableCell")
        tableView.register(UINib(nibName: "ProfileInfoTableCell", bundle: nil), forCellReuseIdentifier: "ProfileInfoTableCell")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 4
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImageTableCell") as! ProfileImageTableCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoTableCell") as! ProfileInfoTableCell
            let uid = Auth.auth().currentUser?.uid
            let userInfoRef = Database.database().reference().child("users").child(uid!)
            userInfoRef.observe(.value) { (snapshot) in
                if let userInfo = snapshot.value as? [String:Any] {
                    if(row == 0) {
                        cell.infoKeyLabel.text = "First Name"
                        cell.infoValueLabel.text = userInfo["firstName"] as? String ?? "--"
                    } else if (row == 1) {
                        cell.infoKeyLabel.text = "Last Name"
                        cell.infoValueLabel.text = userInfo["lastName"] as? String ?? "--"
                    } else if row == 2 {
                        cell.infoKeyLabel.text = "Mobile Number"
                        cell.infoValueLabel.text = userInfo["mobileNumber"] as? String ?? "--"
                    } else if row == 3 {
                        cell.infoKeyLabel.text = "Email"
                        cell.infoValueLabel.text = userInfo["email"] as? String ?? "--"
                    }
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let section = indexPath.section
        let editProfileValuePopUp = setUpEditProfileValuePopUp()
        tableView.deselectRow(at: indexPath, animated: true)
        switch section {
        case 0:
            break
        case 1:
            if(row == 0) {
                editProfileValuePopUp.userInfoBeingEdited = .firstName
            }  else if (row == 1) {
                editProfileValuePopUp.userInfoBeingEdited = .lastName
            } else if row == 2 {
                editProfileValuePopUp.userInfoBeingEdited = .mobileNumber
            } else if row == 3 {
                editProfileValuePopUp.userInfoBeingEdited = .email
            }
            present(editProfileValuePopUp, animated: true, completion: nil)
        default:
            break
        }
    }
    
    // MARK: - CustomAlertViewDelegate
    
    func doneButtonPressed(userInfoBeingEdited: UserInfoBeingEdited, textFieldValue: String) {
        let uid = Auth.auth().currentUser?.uid
        let userInfoRef = Database.database().reference().child("users").child(uid!)
        if(userInfoBeingEdited == .firstName) {
            userInfoRef.updateChildValues([userInfoBeingEdited.rawValue:textFieldValue])
        } else if(userInfoBeingEdited == .lastName) {
            userInfoRef.updateChildValues([userInfoBeingEdited.rawValue:textFieldValue])
        } else if(userInfoBeingEdited == .mobileNumber) {
            userInfoRef.updateChildValues([userInfoBeingEdited.rawValue:textFieldValue])
        } else if (userInfoBeingEdited == .email) {
            userInfoRef.updateChildValues([userInfoBeingEdited.rawValue:textFieldValue])
        }
    }
    
    // MARK: - Private Mathods
    
    private func setUpEditProfileValuePopUp () -> CustomAlertView {
        let editProfileValuePopUp = CustomAlertView(nibName: "CustomAlertView", bundle: nil)
        editProfileValuePopUp.providesPresentationContextTransitionStyle = true
        editProfileValuePopUp.definesPresentationContext = true
        editProfileValuePopUp.modalPresentationStyle = .overCurrentContext
        editProfileValuePopUp.modalTransitionStyle = .crossDissolve
        editProfileValuePopUp.modalPresentationCapturesStatusBarAppearance = true
        editProfileValuePopUp.delegate = self
        return editProfileValuePopUp
    }
}

















