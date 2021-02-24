//
//  TripIssueTableViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 8/28/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class TripIssueTableViewCell : UITableViewCell{
    @IBOutlet var issueLabel: UILabel!
    var label : String = ""
    {
        didSet{
            issueLabel.text = label
        }
    }
    
}
