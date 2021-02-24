//
//  OrderPackageCollectionViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class OrderPackageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var payloadLabel: UITextField!
    
    var delegate: OrderTableViewDelegate?
    
    @IBAction func didEndEditing(_ sender: Any) {
        print("Done editing")
        payloadLabel.resignFirstResponder()
        if let text = payloadLabel.text {
            delegate?.didAddPayloadDescription(text)
        }
    }
}
