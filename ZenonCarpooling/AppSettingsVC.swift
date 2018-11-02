//
//  AppSettingsVC.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/26/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import Localize_Swift

class AppSettingsVC: UITableViewController {
    
    // MARK: - Properties
        
    var chooseLanguageActionsSheet: UIAlertController!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var zUser: ZenonUser!
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ProfileSettingsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsCell")
        tableView.register(UINib(nibName: "SettingsTableCell", bundle: nil), forCellReuseIdentifier: "SettingsTableCell")
        navigationItem.title = "Settings".localized()
        chooseLanguage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUIOnLanguaheChange), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        switch section {
        case 0:
            let uid = Auth.auth().currentUser?.uid
            let userInfoRef = Database.database().reference().child("users").child(uid!)
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSettingsCell") as! ProfileSettingsCell
            userInfoRef.observe(.value) { (snapshot) in
                if let userInfo = snapshot.value as? [String: Any] {
                    cell.emailLabel.text = userInfo["email"] as? String ?? ""
                    let firstName = userInfo["firstName"] as? String ?? ""
                    let lastName = userInfo["lastName"] as? String ?? ""
                    cell.nameLabel.text = "\(firstName) \(lastName)"
                    cell.phoneNumberLabel.text = "\(userInfo["mobileNumber"] as? String ?? "0000")"
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableCell") as! SettingsTableCell
            if(row == 0) {
                cell.settingTitleLabel.text = "Language".localized()
                cell.settingIconImageView.image = #imageLiteral(resourceName: "language-icon")
                cell.secondaryLabel.text = Localize.currentLanguage() == "ar" ? "العربية" : "ِEnglish"
                cell.secondaryLabel.isHidden = false
            } else if (row == 1) {
                cell.settingTitleLabel.text = "Sign Out".localized()
                cell.settingIconImageView.image = #imageLiteral(resourceName: "signout-icon")
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100.0
        case 1:
            return 54.0
        default:
            return 54
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        let section = indexPath.section
        switch section {
        case 0:
            let showOrEditProfileVC = ShowOrEditProfileVC(nibName: "ShowOrEditProfileVC", bundle: nil)
            navigationController?.pushViewController(showOrEditProfileVC, animated: true)
        case 1:
            if (row == 0) {
                present(chooseLanguageActionsSheet, animated: true, completion: nil)
            } else if (row == 1) {
                let signOutAlert = UIAlertController(title: "Sign Out".localized() , message: "Are you sure?".localized(), preferredStyle: .alert)
                signOutAlert.modalPresentationCapturesStatusBarAppearance = true
                let signOutAction = UIAlertAction(title: "Yes".localized(), style: .destructive) { (_) in
                    self.handleSignOut()
                }
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
                signOutAlert.addAction(signOutAction)
                signOutAlert.addAction(cancelAction)
                present(signOutAlert, animated: true, completion: nil)
            } else {
                return
            }
        default:
            return
        }
    }
    
    // MARK: - Handlers and Actions
    
    @objc func updateUIOnLanguaheChange() {
        if(Localize.currentLanguage() == "ar") {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        let splashScreen = SplashScreenVC()
        splashScreen.modalTransitionStyle = .flipHorizontal
        present(splashScreen, animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func handleSignOut() {
        do {
            try Auth.auth().signOut()
            
        } catch let logoutError {
            print(logoutError)
            return
        }
        
        let loginScreen = LoginScreenVC(nibName: "LoginScreenVC", bundle: nil)
        self.view.window?.rootViewController = loginScreen
        self.view.window?.rootViewController!.dismiss(animated: true, completion: nil)
    }
    
    
    func chooseLanguage() {
        chooseLanguageActionsSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        chooseLanguageActionsSheet.modalPresentationCapturesStatusBarAppearance = true
        let chooseArabicLanguageAction = UIAlertAction(title: "العربية", style: .default) { _ in
            Localize.setCurrentLanguage("ar")
            UserDefaults.standard.set("ar", forKey: "i18n_language")
            UserDefaults.standard.set(["ar"], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
        let chooseEnglishLanguageAction = UIAlertAction(title: "English", style: .default) { _ in
            Localize.setCurrentLanguage("en")
            UserDefaults.standard.set("en", forKey: "i18n_language")
            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
        let cancelchooseLanguageAction = UIAlertAction(title: "Cancel".localized(), style: .cancel) { _ in
            self.chooseLanguageActionsSheet.dismiss(animated: true, completion: nil)
        }
        chooseLanguageActionsSheet.addAction(chooseArabicLanguageAction)
        chooseLanguageActionsSheet.addAction(chooseEnglishLanguageAction)
        chooseLanguageActionsSheet.addAction(cancelchooseLanguageAction)
    }

}
