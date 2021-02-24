//
//  AccountSettingsViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 7/22/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

protocol UserDetailsDelegate {
    func didUpdateUserInformation(user: User)
    
}

class AccountSettingViewController:UIViewController{
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var firstNameTextField: UITextField!
    var firstName: String?
    var lastName: String?
    var username: String?
    var delegate : UserDetailsDelegate?
    var user: User?{
        didSet{
            if let currentUser = user{
                firstName = currentUser.firstName
                lastName = currentUser.lastName
                username = currentUser.username
                self.loadViewIfNeeded()
                firstNameTextField.text = currentUser.firstName
                lastNameTextField.text = currentUser.lastName
                usernameTextField.text = currentUser.username
                
            }
        }
    }

    
    override func viewDidLoad() {
        self.saveButton.layer.cornerRadius = 8
        self.saveButton.layer.backgroundColor = UIColor(named: "tint")?.cgColor
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
     

    
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - 180)
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func didTriggerEndFirstName(_ sender: Any) {
         firstNameTextField.resignFirstResponder()
    }
 
    @IBAction func didTriggerEndLastName(_ sender: Any) {
           lastNameTextField.resignFirstResponder()
    }
    
    @IBAction func didTriggerEndUsername(_ sender: Any) {
             usernameTextField.resignFirstResponder()
    }
    
    
    @IBAction func didTapSave(_ sender: UIButton) {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        
        firstName = firstNameTextField.text
        lastName = lastNameTextField.text
        username = usernameTextField.text
        
        let userService = UserService()
        if var currentUser = user{
            currentUser.firstName = firstName
            currentUser.lastName = lastName
            currentUser.username = username
            userService.putUpdateUserInfo(user: currentUser) { (updatedUser) in
                if let user = updatedUser, let userInfoDelegate = self.delegate{
                    userInfoDelegate.didUpdateUserInformation(user: user)
                }
                DispatchQueue.main.async {
                    
                     self.dismiss(animated: true, completion: nil)
                }
               
        }

       
    }
}
    
  

}

