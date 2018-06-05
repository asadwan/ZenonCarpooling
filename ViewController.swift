//
//  ViewController.swift
//  
//
//  Created by Abdullah Adwan on 5/18/18.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        if Auth.auth().currentUser?.uid == nil {
//            handleSignOut()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.navigationItem.title = "Zenon"
        if Auth.auth().currentUser?.uid == nil {
            handleSignOut()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    func handleSignOut() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
            return
        }
        
        let loginScreen = LoginScreenVC(nibName: "LoginScreenVC", bundle: nil)
        present(loginScreen, animated: true, completion: nil)
        //navigationController?.pushViewController(loginScreen, animated: true)
    }
    
    @IBAction func handleLogout(_ sender: Any) {
        handleSignOut()
    }
    
}
