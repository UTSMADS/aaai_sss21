//
//  RecentOrderCollectionViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 7/22/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class RecentOrderSummaryCollectionViewCell: UICollectionViewCell{
    
    var delegate: RecentOrderDelegate?
    var trip: Trip?
    
    @IBOutlet var recentOrderContentView: UIView!
   
    @IBOutlet var dropoffLocationLabel: UILabel!
    @IBOutlet var deliveredToLabel: UILabel!
    @IBOutlet var orderDateLabel: UILabel!
  

    override func layoutSubviews() {
        // cell shadow section
        self.contentView.layer.cornerRadius = 15.0
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor(named: "border")?.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor(named: "shadow")?.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.6
        self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    func setupCell(_ trip: Trip) {
        self.trip = trip
        let tripStatus = self.trip?.tripStatus
        if tripStatus != TripStatus.complete {
             self.deliveredToLabel.text = "Will be delivered to:"
        } else {
            self.deliveredToLabel.text = "Delivered to:"
        }
        
        self.dropoffLocationLabel.text = "\(trip.dropoffLocation.locationName)"
       
        if let startTime = trip.startTime {
            let dateUtil = DateUtil()
             self.orderDateLabel.text = dateUtil.parseDateStringForCalendar(dateString: startTime)
        } else {
             self.orderDateLabel.text = "---"
        }
    }
}
