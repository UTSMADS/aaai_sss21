//
//  ServiceLocationAddScreenViewController.swift
//
//
//  Created by Anurag Rajeev Patil on 02/07/20.
//

import Foundation
import UIKit

class ServiceLocationAddScreenViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var latitudeTextField: UITextField!
    @IBOutlet var longitudeTextField: UITextField!
    @IBOutlet var typeTextField: UITextField!
    @IBOutlet var addButton: UIButton!
    
    var delegate: NewServiceLocationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.layer.cornerRadius = 8
    }

    @IBAction func didTapAddLocButton(_ sender: Any) {
        guard let locationName = nameTextField.text else { return }
        guard let latitudeText = latitudeTextField.text, let latitude = Double(latitudeText) else { return }
        guard let longtitudeText = longitudeTextField.text, let longitude = Double(longtitudeText) else { return }
        guard let locationTypeText = typeTextField.text else { return }
        
        let locationType : LocationType
        
        switch locationTypeText {
        case "dorm":
            locationType = LocationType.dorm
        case "officebuilding":
            locationType = LocationType.officebuilding
        case "library":
            locationType = LocationType.library
        case "restaurant":
            locationType = LocationType.restaurant
        default:
            locationType = LocationType.other
        }
        

        
        let locService = ServiceLocationService()
        locService.createNewServiceLocation(latitude:latitude, longitude:longitude, locationName:locationName, locationType:locationType){
            loc in
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.delegate?.didCreateNewLoc(loc)
                }
            }
        }
    }
    
    @IBAction func didEndEditing(_ sender: UITextField) {
         sender.resignFirstResponder()
     }
     
     @IBAction func didTapCancel(_ sender: Any) {
         DispatchQueue.main.async {
             self.dismiss(animated: true)
        }
    }
}

