//
//  SplashScreenVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 10/28/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit

class SplashScreenVC: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let tabBarStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
            let tabBarVC = tabBarStoryboard.instantiateInitialViewController() as! UITabBarController
            let navigationController = UINavigationController()
            navigationController.viewControllers = [tabBarVC]
            self.view.window?.rootViewController = navigationController
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
