//
//  LoginScreenVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/18/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SVProgressHUD

class LoginScreenVC: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var loginInfoStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpStackBottomSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTestField: UITextField!
    @IBOutlet weak var navigateToSignUpButton: UIButton!
    @IBOutlet weak var recoverPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorsLabel: UILabel!
    @IBOutlet weak var signInInfoStack: UIStackView!
    @IBOutlet weak var continueWithFacebookButton: FBSDKLoginButton!
    
    var zUser: ZenonUser!
    
    var hapticNotification: UINotificationFeedbackGenerator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultStyle(.light)
        hapticNotification = UINotificationFeedbackGenerator()
        errorsLabel.isHidden = true
        continueWithFacebookButton.readPermissions = ["public_profile", "email"]
        
        emailTextField.delegate = self
        passwordTestField.delegate = self
        continueWithFacebookButton.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        loginButton.layer.cornerRadius = 5
        continueWithFacebookButton.layer.cornerRadius = 5
        loginButton.layer.shadowColor = UIColor.black.cgColor
        continueWithFacebookButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        continueWithFacebookButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        loginButton.layer.shadowOpacity = 1.0
        continueWithFacebookButton.layer.shadowOpacity = 1.0
        loginButton.layer.masksToBounds = false
        continueWithFacebookButton.layer.masksToBounds = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: FBSDKLoginButtonDelegate
    
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        //self.dismissKeyboard()
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error.localizedDescription)
            return
        }
        if(result.isCancelled) {
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: (FBSDKAccessToken.current().tokenString))
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResults, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
    }
    
    

    @IBAction func handleLogIn(_ sender: Any) {
        SVProgressHUD.show()
        errorsLabel.isHidden = true
        if let email = emailTextField.text, let password = passwordTestField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let signInError = error {
                    SVProgressHUD.dismiss()
                    self.errorsLabel.text = signInError.localizedDescription
                    self.errorsLabel.isHidden = false
                    self.hapticNotification.notificationOccurred(.error)
                    UIView.animate(withDuration: 0.2, animations: {
                        self.view.layoutIfNeeded()
                    })
                    return
                }
                
                let uid = Auth.auth().currentUser?.uid
                let userInfoRef = Database.database().reference().child("users").child(uid!)
                userInfoRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let infoDict = snapshot.value as? [String: Any]
                    let firstName = infoDict?["firstName"] as? String ?? ""
                    let lastName = infoDict?["lastName"] as? String ?? ""
                    let email = infoDict?["email"] as? String ?? ""
                    let mobileNumber = infoDict?["mobileNumber"] as? Int ?? 0000
                    self.zUser = ZenonUser(firstName: firstName, lastName: lastName, mobileNumber: mobileNumber, email: email)
                })
                SVProgressHUD.dismiss()
                self.dismissKeyboard()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func handleSignUp(_ sender: Any) {
        let signUpVC = SignUpScreenVC(nibName: "SignUpScreenVC", bundle: nil)
        present(signUpVC, animated: true, completion: nil)
    }
    
    @IBAction func handleRecoverPassword(_ sender: Any) {
        let recoverPasswordVC = RecoverPasswordScreenVC(nibName: "RecoverPasswordScreenVC", bundle: nil)
        present(recoverPasswordVC, animated: true, completion: nil)

    }

}

