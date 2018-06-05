//
//  profileImageTableCell.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/27/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit

class ProfileImageTableCell: UITableViewCell {



    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2  + 25
        profileImage.layer.masksToBounds = true
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        self.tintColor = UIColor(white: 0.0, alpha: 0.0)
    }
}
