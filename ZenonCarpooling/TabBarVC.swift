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

class TabBarVC: UITabBarController, FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        handleSignOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser?.uid == nil {
            handleSignOut()
        }
        
        navigationItem.title = "Find a Ride"
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings-icon"), style: .plain, target: self, action: #selector(presentSettingsVC))
        
        //tabBarItem 1
        let vc1 = MyRidesVC(nibName: "MyRidesVC", bundle: nil)
        vc1.tabBarItem = UITabBarItem(title: "My Rides".localized(), image: #imageLiteral(resourceName: "my_rides"), tag: 1)

        //tabBarItem 2
        let vc2 = SearchRideVC(nibName: "SearchRideVC", bundle: nil)
        vc2.tabBarItem = UITabBarItem(title: "Find a Ride".localized(), image: #imageLiteral(resourceName: "search_rides"), tag: 2)

        //tabBarItem 3
        let vc3 = OfferRideVC(nibName: "OfferRideVC", bundle: nil)
        vc3.tabBarItem = UITabBarItem(title: "Offer a Ride".localized(), image: #imageLiteral(resourceName: "add_ride"), tag: 3)
        
        //tabBarItem 4
        let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        let vc4 = chatStoryboard.instantiateViewController(withIdentifier: "Conversations") as! ConversationsVC
        vc4.tabBarItem = UITabBarItem(title: "Chat".localized(), image: #imageLiteral(resourceName: "chat-icon"), tag: 4)

        
        self.viewControllers = [vc1, vc2, vc3, vc4]
        
        self.selectedIndex = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
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
