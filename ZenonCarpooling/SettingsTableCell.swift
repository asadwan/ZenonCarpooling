//
//  SettingsTableCell.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 5/27/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit

class SettingsTableCell: UITableViewCell {

    @IBOutlet weak var settingIconImageView: UIImageView!
    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        secondaryLabel.isHidden = true
        // Initialization code
    }
}
