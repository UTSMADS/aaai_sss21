//
//  ManagerEditProfileViewController.swift
//  
//
//  Created by William Kwon on 7/29/20.
//

import UIKit

class ManagerEditProfileViewController: UIViewController {


    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    var editUserRequest: UpdateUserInfoRequest?
//    var delegate: editUserDelegate?
    var upadatedUser: User?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 8

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        guard let usernameText = usernameTextfield.text else { return }
        guard let passwordText = passwordTextfield.text else {return}
        guard let confirmPasswordText = confirmPasswordTextField.text else {return}
    
        
    
//
//    let userService = UserService()
//        userService.putUpdateUserInfo
// refer add service location
    
    
    }
    
    
    
    
    
    
    

}
