//
//  AuthorizeViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 6/24/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

public class AuthorizeViewController: UIViewController{
    
    @IBOutlet weak var loginButton: GIDSignInButton!
    var idToken:String = ""
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        let radius = 8
        loginButton.layer.cornerRadius = CGFloat(radius)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    @IBAction func prepareForUnwindWithSegue(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindToAuthorizeViewController(_ unwindSegue: UIStoryboardSegue) {
    }
    
    private func alertErrorWithGoogleSignIn() {
        return self.alertGoogleSignIn(
            title: "Failure",
            message: "You must be a UT Austin affliated person to use this app. Your credentials were not recognized as UT Austin affilated."
        )
    }

    private func alertGoogleSignIn(title: String, message: String) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel))
        DispatchQueue.main.async {
            self.present(alertCtrl, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapLoginWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
        loginButton.isEnabled = false
    }
}

extension AuthorizeViewController: GIDSignInDelegate{
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        loginButton.isEnabled = true
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        if let token = user.authentication.idToken {
            //send google id token to backend to see what kind of user is signing in, then navigate to the correct VC
            let authService = AuthenticationService()
            authService.registerUser(idToken: token) { (userTypeInfo) in
                DispatchQueue.main.async {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.registerForPushNotifications()
                    }
                }
                if let values = userTypeInfo {
                    if let userIsManager = values.isManager {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        DispatchQueue.main.async {
                            var viewController:UIViewController
                            if userIsManager {
                                viewController = storyboard.instantiateViewController(identifier: "managerEntryViewController")
                                viewController.modalPresentationStyle = .fullScreen
                                self.present(viewController, animated: true)
                            } else {
                                self.alertError()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertError()
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.alertErrorWithGoogleSignIn()
            }
        }
    }
    
    private func alertError() {
        return self.alert(title: "Failure", message: "There was an issue logging you in. Please use your @utexas.edu email address and make sure you are a registered SMADS manager.")
    }
    
    private func alert(title: String, message: String) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel))
        DispatchQueue.main.async {
            self.present(alertCtrl, animated: true, completion: nil)
        }
    }
}
