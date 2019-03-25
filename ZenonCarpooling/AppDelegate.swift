//
//  AppDelegate.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/18/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
import Localize_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GMSServices.provideAPIKey("AIzaSyDbOqj8iT07nS37umqcPwkLtTk7B3XqDOk")
        GMSPlacesClient.provideAPIKey("AIzaSyDbOqj8iT07nS37umqcPwkLtTk7B3XqDOk")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if(Auth.auth().currentUser == nil) {
            let loginVC = LoginScreenVC()
            window?.rootViewController = loginVC
        } else {
            let navController = UINavigationController()
            let tabBarStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
            let tabBarVC = tabBarStoryboard.instantiateInitialViewController() as! UITabBarController
            navController.viewControllers = [tabBarVC]
            window?.rootViewController = navController
        }
        window?.makeKeyAndVisible()
        
        let uberBlack = UIColor(displayP3Red: 9/255.5, green: 9/255.5, blue: 26/255.5, alpha: 1.0)
        let lightGrey = UIColor(displayP3Red: 230/255.5, green: 230/255.5, blue: 230/255.5, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = uberBlack
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().clipsToBounds = false
        UINavigationBar.appearance().alpha = 1.0
        UINavigationBar.appearance().tintColor = lightGrey
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : lightGrey]
        
        UITabBar.appearance().barTintColor = uberBlack
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = lightGrey
        
        
        if(Localize.currentLanguage() == "ar") {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            UserDefaults.standard.set("ar", forKey: "AppleLanguages")
            UserDefaults.standard.set("ar", forKey: "i18n_language")
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

