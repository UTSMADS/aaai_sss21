//
//  CustomerTabBarControllerViewController.swift
//  SMADS Customer
//
//  Created by Asha Jain on 10/10/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import UIKit

class CustomerTabBarController: UITabBarController, UITabBarControllerDelegate, UINavigationControllerDelegate {

    var ordersNavigationViewController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0, let vc = viewController as? UINavigationController {
            ordersNavigationViewController = vc
            vc.delegate = self
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedIndex == 0 {
            if let vc = viewController as? UINavigationController {
                let last = vc.viewControllers.last
                if last is QueuedTripViewController || last is ActiveTripViewController || last is ConfirmPickupViewController {
                    return false
                }
            }
        }
        return true
    }
}
