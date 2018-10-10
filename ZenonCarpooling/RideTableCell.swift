//
//  RideTableCell.swift
//  ZenonCarpooling
//
//  Created by Abdullah Adwan on 6/12/18.
//  Copyright © 2018 Abdullah Adwan. All rights reserved.
//

import UIKit

class RideTableCell: UITableViewCell {

    var ride: Ride!
    @IBOutlet weak var rideFromLabel: UILabel!
    @IBOutlet weak var rideToLabel: UILabel!
    @IBOutlet weak var rideDateandTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
//        rideFromLabel.text = "\(ride.leavingFromNeighborhood) - \(ride.leavingFromCity)"
//        rideToLabel.text = "\(ride.goingToNeighborhood) - \(ride.goingToCity)"
//        rideDateandTimeLabel.text = "\(ride.outboundRideDateAndTime.getDateTimeString()!)"
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
