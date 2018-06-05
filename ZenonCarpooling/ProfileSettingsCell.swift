//
//  TableCell.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/26/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit

class ProfileSettingsCell: UITableViewCell {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.bounds.height / 2
        profilePictureImageView.layer.masksToBounds = true
    }
}
