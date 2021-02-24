//
//  LemonadeDropoffTableViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 7/26/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class LemonadeDropoffTableViewCell: UITableViewCell{
    
    @IBOutlet var locationAcronymLabel: UILabel!
    @IBOutlet var etaLabel: UILabel!
    @IBOutlet var buildingNameLabel: UILabel!
    
    var displayServiceLocation: ServiceLocation! {
        didSet{
            buildingNameLabel.text = displayServiceLocation.locationName
            locationAcronymLabel.text = displayServiceLocation.acronym
            if let eta = displayServiceLocation.eta
            {
                etaLabel.text = "\(eta) MINS"

            }
            
            
        }
    }
   
    
}
