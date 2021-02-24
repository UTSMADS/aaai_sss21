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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Override point for customization after application launch.
        GoogleSignInManager.setup()
        socketManager.connect()
        socketManager.subscribeToSpotAlert()
        UIApplication.shared.applicationIconBadgeNumber = 0
        var vcIdentifier = "authorizeRootNavigationController"
        let tabNumber = 0
        if !(UserDefaults.standard.string(forKey: NetworkConstants.tokenKey)?.isEmpty ?? true) {
            let authenticationService = AuthenticationService()
            authenticationService.validateToken { response in
                if let tokenRepsonse = response, !(tokenRepsonse.customer ?? false) {
                    vcIdentifier = "managerEntryViewController"
                    self.presentViewController(named: vcIdentifier, tabNumber, nil)
                } else {
                    self.presentViewController(named: vcIdentifier, nil, nil)
                }
            }
        } else {
            //User does not have a token saved so go to login screen
            self.presentViewController(named: vcIdentifier, nil, nil)
        }
        registerForPushNotifications()
        return true
    }
    
    func presentViewController(named identifier: String, _ tabIndex : Int?, _ dataHandler: [String: Any]?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        DispatchQueue.main.async {
            let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
            
            if identifier == "authorizeRootNavigationController"{
                
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
        notificationeService.saveTokenForUser(token: token, manager: true)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error while registering for notifications: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier.contains("missingRobot-") {
            // Go to the robots tab
            if let tabVC = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                let index = 0
                tabVC.selectedViewController = tabVC.viewControllers?[index]
                tabVC.selectedIndex = index
                if let navController = tabVC.selectedViewController as? UINavigationController, !navController.viewControllers.isEmpty, let spotsVC = navController.viewControllers[0] as? ManageSpotsViewController {
                    spotsVC.loadSpots()
                }
            }
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.identifier.contains("missingRobot-") {
            // Go to the robots tab
            if let tabVC = UIApplication.shared.windows.first?.rootViewController as? UITabBarController, !(tabVC.viewControllers?.isEmpty ?? false), let navController = tabVC.viewControllers?[0] as? UINavigationController, !navController.viewControllers.isEmpty, let spotsVC = navController.viewControllers[0] as? ManageSpotsViewController {
                    spotsVC.loadSpots()
            }
        }
        completionHandler([.badge, .sound, .alert])
    }
}
