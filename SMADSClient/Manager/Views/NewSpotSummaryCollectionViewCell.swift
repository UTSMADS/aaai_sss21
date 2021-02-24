//
//  NewSpotSummaryCollectionViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 7/17/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class NewSpotSummaryCollectionViewCell: UICollectionViewCell
{
    var delegate : NewSpotDelegate?
    var name: String?
    var id: Int?
    var mId: Int?
    var password: String?
    var ipAddress :String?
    
    @IBOutlet var robotNameLabel: UILabel!
    
    @IBOutlet var robotNumberLabel: UILabel!
    @IBOutlet var manufacturerIDLabel: UILabel!
    @IBOutlet var ipAddressLabel: UILabel!
    @IBOutlet var addSpotButton: UIButton!
    
    func setupCell(){
        addSpotButton.layer.cornerRadius = 8
    }
    
    func updateCell(name: String, number: Int, mID: Int, ip: String){
        self.robotNameLabel.text = name
        self.robotNumberLabel.text = "\(number)"
        self.manufacturerIDLabel.text = "\(mID)"
        self.ipAddressLabel.text = ip
        
        self.name = name
        self.id = number
        self.mId = mID
        self.ipAddress = ip
        
    }
    
    @IBAction func didTapAddSpot(_ sender: Any) {
        //Need to create a new spot request object and send to backend to create new spot
            delegate?.didCreateNewSpot()
        }
        
    
}
