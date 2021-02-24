//
//  SpotDetailsTableViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 6/25/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class SpotDetailsTableViewCell: UITableViewCell{
    
    @IBOutlet var tripIdLabel: UILabel!
    
    @IBOutlet var tripStatus: UILabel!
    @IBOutlet var dropoffLabel: UILabel!
    @IBOutlet var pickupLabel: UILabel!
    
    var trip: Trip? {
        didSet {
            if let trip = trip {
                self.tripIdLabel.text = "Order ID: \(trip.id)"
                self.tripStatus.text = "\(trip.tripStatus)"
                self.pickupLabel.text = "Pickup: \(trip.pickupLocation.locationName)"
                self.dropoffLabel.text = "Dropoff: \(trip.dropoffLocation.locationName)"
            }
        }
    }
    
}
