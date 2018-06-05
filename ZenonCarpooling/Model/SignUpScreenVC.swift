//
//  SignUpScreenVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/18/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import Firebase
import libPhoneNumber_iOS

class SignUpScreenVC: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var signUpStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var termAndConditionsLabelBottomSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpInfoStack: UIStackView!
    var hapticNotification: UINotificationFeedbackGenerator!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set adaptive constraints to UI Elements
        
        let screenHeight =  UIScreen.main.bounds.height
        let screenWidth  = UIScreen.main.bounds.width

        signUpStackWidthConstraint.constant = screenWidth * 0.72
        logoWidthConstraint.constant = screenWidth * 0.26666
        logoHeightConstraint.constant = screenWidth * 0.26666
        
        let signUpButtonWidthMultiplier: CGFloat = 0.64
        let signUpButtonHeightMultiplier: CGFloat = 0.075
        
        if(screenWidth < 375.0) {
            signUpButtonWidthConstraint.constant = screenWidth  * signUpButtonWidthMultiplier
            signUpButtonHeightConstraint.constant = screenHeight * signUpButtonHeightMultiplier
            termAndConditionsLabelBottomSpacingConstraint.constant = 24.0
            signUpInfoStack.spacing = 24.0
        }

        // use haptic feedback
        hapticNotification = UINotificationFeedbackGenerator()
        
        //warning label is initially hidden
        warningLabel.isHidden = true
        
        //Make sign up button rounded
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.masksToBounds = false 
        
        // Dismiss keyboard when touching anywhere 
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func presentSignUpWarning(warning: String) {
        self.hapticNotification.notificationOccurred(.error)
        self.warningLabel.isHidden = false
        self.warningLabel.text = warning
        self.warningLabel.sizeToFit()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Actions

    @IBAction func handleCancelSignUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleSigningUp(_ sender: Any) {
            warningLabel.text = ""
            if let firstname = firstNameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let mobileNumber = mobileNumberTextField.text {
                
                // Check the validilty of mobile number
                let phoneUtil = NBPhoneNumberUtil()
                var formattedMobileNumber: String = ""
                do {
                    let phoneNumber = try phoneUtil.parse(mobileNumber, defaultRegion: "JO")
                    let internationalFormattedString = try phoneUtil.format(phoneNumber, numberFormat: .INTERNATIONAL)
                    formattedMobileNumber = internationalFormattedString
                    let phoneNumberType = phoneUtil.getNumberType(phoneNumber)
                    if(phoneNumberType != .MOBILE) {
                        let warningString = "Please use mobile phone numbers only"
                        mobileNumberTextField.text = ""
                        presentSignUpWarning(warning: warningString)
                        return
                    }
                } catch let error as NSError {
                    mobileNumberTextField.text = ""
                    if(error.code == 0) {
                        presentSignUpWarning(warning: "Invalid mobile number.")
                    }
                    return
                }
                
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if let signUpError = error {
                        let warningString = signUpError.localizedDescription
                        print(warningString)
                        self.presentSignUpWarning(warning: warningString)
                        return
                    }
                    
                    guard let userId = user?.uid else {
                        self.presentSignUpWarning(warning: "Somthing went wrong, please try again.")
                        return
                    }
                    
                    let dbRef = Database.database().reference(fromURL: "https://zenoncarpooling.firebaseio.com/")
                    let usersListRef = dbRef.child("users")
                    let userRef = usersListRef.child(userId)
                    
                    let userInfo = ["firstName":firstname, "lastName": lastName, "email": email, "password": password, "mobileNumber": formattedMobileNumber]
                    userRef.updateChildValues(userInfo)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
        }
    }
    
}