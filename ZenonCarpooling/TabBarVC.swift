//
//  MainScreen.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/18/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import Localize_Swift
import Material

class TabBarVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser?.uid == nil {
            handleSignOut()
        }
        
        navigationItem.title = "Find a Ride".localized()
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings-icon"), style: .plain, target: self, action: #selector(presentSettingsVC))
        
        
        
        self.selectedIndex = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        
        // Add chatVC to tabs
        let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        let tabBarStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
        let chatVC = chatStoryboard.instantiateViewController(withIdentifier: "Conversations") as! ConversationsVC
        chatVC.tabBarItem = UITabBarItem(title: "Chat".localized(), image: #imageLiteral(resourceName: "chat-icon"), tag: 4)
        viewControllers![3] = chatVC
        
        // Add offer ride vc
        let offerRideVC = tabBarStoryboard.instantiateViewController(withIdentifier: "OfferRideVC")
        let snackbarVC = SnackbarController(rootViewController: offerRideVC)
        snackbarVC.tabBarItem = UITabBarItem(title: "Offer a Ride".localized(), image: #imageLiteral(resourceName: "add_ride"), tag: 3)
        viewControllers![2] = snackbarVC
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func presentSettingsVC() {
        let settingsVC = AppSettingsVC(nibName: "AppSettingsVC", bundle: nil)
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc func handleSignOut() {
        do {
            try Auth.auth().signOut()
            
        } catch let logoutError {
            print(logoutError)
            return
        }
        
        let loginScreen = LoginScreenVC(nibName: "LoginScreenVC", bundle: nil)
        present(loginScreen, animated: true, completion: nil)
    }
    
    @objc func updateLanguage() {
        self.viewControllers![0].tabBarItem.title = "My Rides".localized()
        self.viewControllers![1].tabBarItem.title = "Find a Ride".localized()
        self.viewControllers![2].tabBarItem.title = "Offer a Ride".localized()
        self.viewControllers![3].tabBarItem.title = "Chat".localized()
    }
}
