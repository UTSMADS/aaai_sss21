//
//  ManagerTableViewCell.swift
//  SMADS Manager
//
//  Created by Asha Jain on 10/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import UIKit

class ManagerTableViewCell: UITableViewCell {

    var managerEmailAddress: String? {
        didSet {
            label.text = managerEmailAddress
        }
    }
    
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
