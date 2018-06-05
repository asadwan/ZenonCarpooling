//
//  CustomAlertView.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/28/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import libPhoneNumber_iOS

public enum UserInfoBeingEdited: String {
    case firstName = "firstName"
    case lastName = "lastName"
    case mobileNumber = "mobileNumber"
    case email = "email"
}

class CustomAlertView: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var editedValueTextFeild: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var jordanFlagImageView: UIImageView!
    @IBOutlet weak var jordanPhoneExtLabel: UILabel!
    
    var userInfoBeingEdited: UserInfoBeingEdited!
    var hapticNotification = UINotificationFeedbackGenerator()
    var delegate: CustomAlertViewDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.isOpaque = false
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        editedValueTextFeild.placeHolderColor = UIColor.darkGray
        warningLabel.isHidden = true
        editedValueTextFeild.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        alertView.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        doneButton.addBorder(side: .Left, color: UIColor.black, width: 1)
    }
    
    // MARK: - Private Methods

    private func setupView() {
        if (userInfoBeingEdited == .firstName) {
            jordanFlagImageView.isHidden = true
            jordanPhoneExtLabel.isHidden = true
            editedValueTextFeild.placeholder = "First Name"
        } else if (userInfoBeingEdited == .lastName) {
            jordanFlagImageView.isHidden = true
            jordanPhoneExtLabel.isHidden = true
            editedValueTextFeild.placeholder = "Last Name"
        } else if (userInfoBeingEdited == .mobileNumber) {
            editedValueTextFeild.placeholder = "Mobile Number"
            jordanPhoneExtLabel.sizeToFit()
            editedValueTextFeild.textAlignment = .left
            editedValueTextFeild.keyboardType = .phonePad
        } else if (userInfoBeingEdited == .email) {
            jordanFlagImageView.isHidden = true
            jordanPhoneExtLabel.isHidden = true
            editedValueTextFeild.keyboardType = .emailAddress
            editedValueTextFeild.placeholder = "Email"
        }
    }

    private func animateView() {
        alertView.alpha = 0
        alertView.frame.origin.y = alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4) {
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        }
    }
    
    @IBAction func handleDoneButtonTapped(_ sender: Any) {
        var editedValue = editedValueTextFeild.text
        if(editedValue == "") {
            hapticNotification.notificationOccurred(.error)
            warningLabel.text = "Field cannot be empty"
            warningLabel.isHidden = false
            return
        }
        if (userInfoBeingEdited == .mobileNumber) {
            let phoneUtil = NBPhoneNumberUtil()
            do {
                let phoneNumber: NBPhoneNumber = try phoneUtil.parse(editedValue, defaultRegion: "JO")
                let internationalFormattedString: String = try phoneUtil.format(phoneNumber, numberFormat: .INTERNATIONAL)
                editedValue = internationalFormattedString
                
                let numberType = phoneUtil.getNumberType(phoneNumber)
                if(numberType != .MOBILE) {
                    warningLabel.text = "Please provide a mobile number only"
                    hapticNotification.notificationOccurred(.error)
                    return
                }
            }
            catch let error as NSError {
                if(error.code == 0) {
                    warningLabel.text = "Not a number"
                    warningLabel.isHidden = false
                    hapticNotification.notificationOccurred(.error)
                    return
                }
                print(error.localizedDescription)
            }
        }
        delegate?.doneButtonPressed(userInfoBeingEdited: userInfoBeingEdited, textFieldValue: editedValue!)
        editedValueTextFeild.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleCancelButtonTapped(_ sender: Any) {
        editedValueTextFeild.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
}


protocol CustomAlertViewDelegate: class {
    func doneButtonPressed(userInfoBeingEdited: UserInfoBeingEdited, textFieldValue: String)
}
