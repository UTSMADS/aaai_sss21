//
//  SpotTableViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 6/15/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class SpotTableViewCell: UITableViewCell{
    var spot: Spot? {
        didSet {
            if let spot = spot {
                spotIDLabel.text = "ID: \(spot.manufacturerID)"
                spotBatteryLabel.text = "Battery: \(spot.chargeLevel)%"
                spotStatusLabel.text = "Status: \(spot.status)"
                spotNameLabel.text = spot.name
                spotStatusLight.layer.cornerRadius = spotStatusLight.bounds.width / 2

                switch spot.status {
                case .outofservice:
                    spotStatusLight.backgroundColor = .red
                    backgroundColor = UIColor(red: 255/255, green: 135/255, blue: 135/255, alpha: 1)
                case .reconnectingToInternet:
                    spotStatusLight.backgroundColor = .orange
                    backgroundColor = UIColor(red: 255/255, green: 191/255, blue: 135/255, alpha: 1)
                default:
                    spotStatusLight.backgroundColor = .green
                    backgroundColor = .white
                }
            }
        }
    }
    @IBOutlet var spotIDLabel: UILabel!
    @IBOutlet var spotBatteryLabel: UILabel!
    @IBOutlet var spotStatusLabel: UILabel!
    @IBOutlet var spotNameLabel: UILabel!
    @IBOutlet var spotStatusLight: UIView!
}
