//
//  LemonadeRequestViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 7/26/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class LemonadeRequestViewController:UIViewController{
    
    @IBOutlet var requestLemonadeButton: UIButton!
    @IBOutlet weak var storeClosedView: UIView!
    @IBOutlet weak var storeDescriptionLabel: UILabel!
    @IBOutlet weak var storeClosedBackgroundView: UIView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    var refreshBarButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        requestLemonadeButton.layer.cornerRadius = 8
        getStoreDetails()
        refreshBarButton = refreshButton
    }
    
    func getStoreDetails() {
        print("Getting store details")
        let storeService = StoreService()
        storeService.getStoreDetails { (storeResp) in
            if let store = storeResp {
                if !store.open {
                    // Store is closed
                    DispatchQueue.main.async {
                        self.storeDescriptionLabel.text = store.hoursDescription
                        self.storeClosedView.isHidden = false
                        self.storeClosedBackgroundView.layer.cornerRadius = 8
                            self.requestLemonadeButton.isEnabled = false
                        self.navigationItem.rightBarButtonItem = self.refreshBarButton
                    }
                } else {
                    DispatchQueue.main.async {
                        self.storeClosedView.isHidden = true
                        self.navigationItem.rightBarButtonItem = nil
                        self.requestLemonadeButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func didTapRefreshStoreStatus(_ sender: UIBarButtonItem) {
        getStoreDetails()
    }

    @IBAction func didTapRequestLemonade(_ sender: UIButton) {
    }
    
    @IBAction func unwindToLemonadeRequestVC( _ seg: UIStoryboardSegue) {
      }
}
