//
//  RequestViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class RequestViewController: UIViewController{
    var pickupServiceLocation : ServiceLocation!
    var dropoffServiceLocation: ServiceLocation!
    var bookTitle: String!
    
   
    @IBOutlet var editPickupLocationButton: UIButton!
    @IBOutlet var selectedPickupLocationLabel: UILabel!
    @IBOutlet var selectedPickupLocationNameLabel: UILabel!
    
    @IBOutlet var editDropoffLocationButton: UIButton!
    @IBOutlet var selectedDropoffLocationLabel: UILabel!
    @IBOutlet var selectedDropoffLocationNameLabel: UILabel!
    @IBOutlet var requestButton: UIButton!
    @IBOutlet var packageNameLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Request a Book Delivery"
        setUpView()
        
    }
    
    func setUpView()
    {
        
    }
    
     
  
}

