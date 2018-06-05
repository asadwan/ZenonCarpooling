//
//  RecoverPasswordScreenVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/18/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import Firebase

class RecoverPasswordScreenVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var whiteViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var recoverPasswordButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var recoverPasswordButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var recoverPasswordButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cancelRecoveringPasswordButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        let screenHeight =  UIScreen.main.bounds.height
        let screenWidth  = UIScreen.main.bounds.width
        
        // Make recoverPasswordButton rounded
        recoverPasswordButton.layer.cornerRadius = 5
        recoverPasswordButton.layer.masksToBounds = false
        
        //UI Elements constraints
        if(screenWidth < 375 ) {
            recoverPasswordButtonWidthConstraint.constant = screenWidth *  0.64
            recoverPasswordButtonHeightConstraint.constant = screenHeight * 0.075
        }
        
        emailTextField.delegate = self

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    // MARK: Actions

    @IBAction func handleCancelRecoveringPassword(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func handleRecoveringPassword(_ sender: Any) {
        if let email = emailTextField.text {
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if let err = error {
                    let alert = UIAlertController(title: "Error recovering password", message: err.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                let msg = "Please check your email for further instructions"
                let alert = UIAlertController(title: "Success", message: msg, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}
