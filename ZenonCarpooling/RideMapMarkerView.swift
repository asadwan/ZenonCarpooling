//
//  RideMapMarkerView.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 10/16/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit

class RideMapMarkerView: UIView {

    @IBOutlet weak var fromLocationLabel: UILabel!
    @IBOutlet weak var toLocationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "RideMapMarkerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override func awakeFromNib() {
        self.clipsToBounds = true
    }

}
