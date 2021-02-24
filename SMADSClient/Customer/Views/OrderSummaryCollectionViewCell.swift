//
//  OrderSummaryCollectionViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class OrderSummaryCollectionViewCell: UICollectionViewCell {

    @IBOutlet var packageContentLabel: UILabel!
    @IBOutlet var pickupLocationLabel: UILabel!
    @IBOutlet var dropoffLocationLabel: UILabel!
    
    @IBOutlet var requestButton: UIButton!
    
    var delegate: OrderTableViewDelegate?
    
    func setupCell() {
        requestButton.layer.cornerRadius = 8
    }
    
    func updateCell(pickupLocation: ServiceLocation, dropoffLocation: ServiceLocation, packageContent: String) {
        packageContentLabel.text = packageContent
        pickupLocationLabel.text = "\(pickupLocation.locationName) (\(pickupLocation.locationType))"
        dropoffLocationLabel.text = "\(dropoffLocation.locationName) (\(dropoffLocation.locationType))"
    }
    
    @IBAction func didTapRequest(_ sender: Any) {
        delegate?.didConfirmRequest()
    }
}
