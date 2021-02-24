//
//  NewSpotBasicInfoCollectionViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 7/17/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class NewSpotBasicInfoCollectionViewCell : UICollectionViewCell{
    var delegate : NewSpotDelegate?
    
    @IBOutlet var robotNameTextField: UITextField!
    
    @IBOutlet var robotNumberTextField: UITextField!
    
    @IBAction func didEndEditingRobotName(_ sender: UITextField) {
        print("Done editing robot name field")
        robotNameTextField.resignFirstResponder()
        if let text = robotNameTextField.text {
            delegate?.didAddRobotName(value: text)
            robotNumberTextField.becomeFirstResponder()
        }
    }
    @IBAction func didEndEditingRobotNumber(_ sender: UITextField) {
        print("Done editing robot number field")
        robotNumberTextField.resignFirstResponder()
        if let text = robotNumberTextField.text {
            delegate?.didAddRobotNumber(value: text)
        }
    }
}
