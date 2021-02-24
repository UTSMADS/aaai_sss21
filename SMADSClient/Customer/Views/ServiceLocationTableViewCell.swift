//
//  ServiceLocationTableViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class ServiceLocationTableViewCell: UITableViewCell {
    
    @IBOutlet var buildingNameLabel: UILabel!
    
    
    func setupCell(name: String, type: String) {
        self.buildingNameLabel.text = name
       
    }
}
