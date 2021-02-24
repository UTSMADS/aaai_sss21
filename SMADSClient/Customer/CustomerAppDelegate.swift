//
//  AppDelegate.swift
//  Smds_app
//
//  Created by William Kwon on 6/10/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import UIKit
import GoogleSignIn
import LocalAuthentication
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Override point for customization after application launch.
        GoogleSignInManager.setup()
        socketManager.connect()
        registerForPushNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        var vcIdentifier = "authorizeRootNavigationController"
        let tabNumber = 0
        if UserDefaults.standard.string(forKey: NetworkConstants.tokenKey)?.isEmpty == false {
            let authenticationService = AuthenticationService()
            authenticationService.validateToken { response in
                if let tokenRepsonse = response, tokenRepsonse.customer ?? false {
                    if let customerTrip = tokenRepsonse.activeTrip {
                        if customerTrip.tripStatus == .dropoff {
                            vcIdentifier = "ConfirmPickupViewController"
                            let dataHandler = ["ConfirmPickupViewController": customerTrip]
                            self.presentViewController(named:  vcIdentifier, tabNumber, dataHandler as [String : Any])
                            
                        } else if customerTrip.spotManufacturerID != nil {
                            vcIdentifier = "ActiveTripViewController"
                            let dataHandler = ["ActiveTripViewController": customerTrip]
                            self.presentViewController(named:  vcIdentifier, tabNumber, dataHandler as [String : Any])
                        } else {
                            vcIdentifier = "QueuedTripViewController"
                            let dataHandler = ["QueuedTripViewController": customerTrip]
                            self.presentViewController(named:  vcIdentifier, tabNumber, dataHandler as [String : Any])
                        }
                    } else {
                        vcIdentifier = "clientEntryViewController"
                        self.presentViewController(named: vcIdentifier, tabNumber, nil)
                    }
                } else {
                    //User's token was not valid so show the login screen
                    self.presentViewController(named: vcIdentifier, nil, nil)
                }
            }
        } else {
            //User does not have a token saved so go to login screen
            self.presentViewController(named: vcIdentifier, nil, nil)
        }
        
        return true
    }
        
    func presentViewController(named identifier: String, _ tabIndex : Int?, _ dataHandler: [String: Any]?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        DispatchQueue.main.async {
            let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
            
            if identifier == "authorizeRootNavigationController" {
                UIApplication.shared.windows.first?.rootViewController = viewController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            } else if identifier == "managerEntryViewController" {
                UIApplication.shared.windows.first?.rootViewController = viewController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
                if let tabIndex = tabIndex {
                    if let tbController = viewController as? UITabBarController {
                        tbController.selectedViewController = tbController.viewControllers?[tabIndex]
                    }
                    viewController.tabBarController?.selectedIndex = tabIndex
                }
            } else {
                let rootVC = storyboard.instantiateViewController(identifier: "clientEntryViewController")
                UIApplication.shared.windows.first?.rootViewController = rootVC
                UIApplication.shared.windows.first?.makeKeyAndVisible()
                
                if let tabIndex = tabIndex {
                    if let tbController = rootVC as? UITabBarController{
                        tbController.selectedViewController = tbController.viewControllers?[tabIndex]
                        tbController.selectedIndex = tabIndex
                    }
                }
                
                if identifier == "ActiveTripViewController" {
                    if let data = dataHandler {
                        if let trip = data[identifier] as? Trip, let viewController = viewController as? ActiveTripViewController {
                            viewController.trip = trip
                        }
                    }
                    if let tbController = rootVC as? UITabBarController {
                        if let navigationController = tbController.selectedViewController as? UINavigationController {
                            navigationController.pushViewController(viewController, animated: true)
                        }
                    }
                } else if identifier == "QueuedTripViewController" {
                    if let data = dataHandler {
                        if let trip = data[identifier] as? Trip, let viewController = viewController as? QueuedTripViewController {
                            viewController.trip = trip
                        }
                    }
                    
                    if let tbController = rootVC as? UITabBarController {
                        if let navigationController = tbController.selectedViewController as? UINavigationController{
                            navigationController.pushViewController(viewController, animated: true)
                        }
                    }
                } else if identifier == "ConfirmPickupViewController" {
                    if let data = dataHandler {
                        if let trip = data[identifier] as? Trip, let viewController = viewController as? ConfirmPickupViewController {
                            viewController.trip = trip
                        }
                    }
                    
                    if let tbController = rootVC as? UITabBarController {
                        if let navigationController = tbController.selectedViewController as? UINavigationController{
                            navigationController.pushViewController(viewController, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
}

extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

// User Notification stuff
extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx",  $0) }.joined()
        let notificationeService = NotificationService()
        notificationeService.saveTokenForUser(token: token, manager: false)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer {
            completionHandler()
        }
        print("User tapped push notification")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error while registering for notifications: \(error)")
    }
}
