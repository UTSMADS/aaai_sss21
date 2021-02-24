//
//  UserHistoryTableViewCell.swift
//  Smds_app
//
//  Created by William Kwon on 7/1/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import UIKit

class UserHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet var robotImageView: UIImageView!
    @IBOutlet var orderDateLabel: UILabel!
    @IBOutlet var orderNumberLabel: UILabel!
    
    var trip: Trip?{
        didSet{
            if let trip = trip{
               let dateUtil = DateUtil()
                var startDate = ""
                if let startTime = trip.startTime {
                      startDate =  dateUtil.parseDateStringForCalendar(dateString: startTime)
                    
                }
                else{
                    startDate = "----"
                }
                self.orderDateLabel.text = startDate
                self.robotImageView.image = UIImage(named: "lemon")
                self.orderNumberLabel.text = "Order #\(trip.id)"
            }
        }
    }
}
