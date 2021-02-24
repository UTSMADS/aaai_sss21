//
//  NewSpotTechnicalInfoCollectionViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 7/17/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class NewSpotTechnicalInfoCollectionViewCell : UICollectionViewCell{
    
    var delegate : NewSpotDelegate?
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var ipAddressTextField: UITextField!
    @IBOutlet var manufacturerIDTextField: UITextField!
    
    
    @IBAction func didEndEditingMid(_ sender: UITextField) {
        manufacturerIDTextField.resignFirstResponder()
        if let text = manufacturerIDTextField.text {
            delegate?.didAddManufacturerID(value: text)
        }
        ipAddressTextField.becomeFirstResponder()
    }
    
    @IBAction func didEndEditingIPAddress(_ sender: UITextField) {
        ipAddressTextField.resignFirstResponder()
        if let text = ipAddressTextField.text {
            delegate?.didAddIpAddress(value: text)
        }
        passwordTextField.becomeFirstResponder()
    }
    
    
    @IBAction func didEndEditingPassword(_ sender: UITextField) {
        passwordTextField.resignFirstResponder()
        if let text = passwordTextField.text {
            delegate?.didAddPassword(value: text)
        }
    }
}
