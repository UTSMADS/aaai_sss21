//
//  AccountManagementTableVIewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 7/22/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class AccountManagementTableViewCell : UITableViewCell{
    
    @IBOutlet var accountManangementNameLabel: UILabel!
    func setupCell(_ label: String){
        
        accountManangementNameLabel.text = label
        
    }
}
