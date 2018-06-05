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

class TabBarVC: UITabBarController, FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        handleSignOut()
    }
    
    override func viewDidLoad() {
        
        navigationItem.title = "Find a Ride"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings-icon"), style: .plain, target: self, action: #selector(presentSettingsVC))
        
        super.viewDidLoad()
        self.tabBar.barStyle = UIBarStyle.blackOpaque
        
        //tabBarItem 1
        let vc1 = ViewController(nibName: "ViewController", bundle: nil)
        vc1.tabBarItem = UITabBarItem(title: "Rides", image: #imageLiteral(resourceName: "my_rides"), tag: 1)

        //tabBarItem 2
        let vc2 = SearchRideVC(nibName: "SearchRideVC", bundle: nil)
        vc2.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "search_rides"), tag: 2)

        //tabBarItem 3
        let vc3 = ViewController(nibName: "ViewController", bundle: nil)
        vc3.tabBarItem = UITabBarItem(title: "Offer", image: #imageLiteral(resourceName: "add_ride"), tag: 3)
        
        //tabBarItem 4
        let vc4 = ViewController(nibName: "ViewController", bundle: nil)
        vc4.tabBarItem = UITabBarItem(title: "Chat", image: #imageLiteral(resourceName: "chat-icon"), tag: 4)

        
        self.viewControllers = [vc1, vc2, vc3, vc4]
        self.selectedIndex = 1
        let uid = Auth.auth().currentUser?.uid
        if uid == nil {
            handleSignOut()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.selectedIndex = 1
        if Auth.auth().currentUser?.uid == nil {
            handleSignOut()
        }
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
}