//
//  MyAccountManagerViewController.swift
//  Smds_app
//
//  Created by Anurag Rajeev Patil on 05/08/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import UIKit

class MyAccountManagerViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    var user :User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logoutButton.layer.cornerRadius = 8
        self.logoutButton.layer.borderColor = UIColor(named: "tint")?.cgColor
        self.logoutButton.layer.borderWidth = 1
        
        let userService = UserService()
        userService.getUserInfo { (userInfo) in
            if let user = userInfo {
                if let firstName = user.firstName, let lastName = user.lastName, let username = user.username{
                    DispatchQueue.main.async {
                        self.nameLabel.text = firstName + " " +  lastName
                        self.usernameLabel.text = username
                    }
                    self.user = user
                }
            }
        }
    }

    @IBAction func didTapLogOut(_ sender: UIButton) {
        let authenticationService = AuthenticationService()
        authenticationService.logout()

        if let authorizeVC = self.storyboard?.instantiateViewController(withIdentifier: "authorizeRootNavigationController") as? UINavigationController {
            authorizeVC.modalPresentationStyle = .fullScreen
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromLeft
            view.window!.layer.add(transition, forKey: kCATransition)
            DispatchQueue.main.async {
                self.present(authorizeVC, animated: false, completion: nil)
            }
        }
    }
}
