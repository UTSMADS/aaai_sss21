//
//  LemonadeOrderSummaryViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 7/26/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class LemonadeOrderSummaryViewController: UIViewController{
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var estimatedDeliveryTimeLabel: UILabel!
    @IBOutlet var orderDrinkButton: UIButton!
    @IBOutlet var serviceLocationLabel: UILabel!
    
    var dropoffLocation : ServiceLocation? {
        didSet{
            self.loadViewIfNeeded()
            self.activityIndicator.isHidden = true
            if let dropoffLoc = dropoffLocation{
                serviceLocationLabel.text = dropoffLoc.locationName
                let eta = calculateETA(dropoffLoc.eta);
                estimatedDeliveryTimeLabel.text = eta
            }else{
                serviceLocationLabel.text = "---"
                estimatedDeliveryTimeLabel.text = "---"
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        orderDrinkButton.layer.cornerRadius = 8
        activityIndicator.style = .large
        activityIndicator.color = UIColor(named: "tint")
        self.activityIndicator.isHidden = true
        
        
    }
    
    func calculateETA(_ travelTime: Int?)-> String{
        let currentTime = Date()
        if let time = travelTime{
            
            let eta = currentTime.addingTimeInterval(Double(time * 60))
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            return "\(dateFormatter.string(from: eta))"
        }else{
            return "---"
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "lemonadeActiveTripSegue"{
//            if let destination = segue.destination as? ActiveTripViewController {
//                if let trip = self.confirmedTrip, let dropoffloc = dropoffLocation {
//                    destination.trip = trip
//                    if let eta = dropoffloc.eta{
//                        destination.eta = eta
//                    }
//                }
//            }
//        } else if segue.identifier == "queuedTripSegue"{
//            if let destination = segue.destination as? QueuedTripViewController{
//                if var trip = self.confirmedTrip, let dpLoc = dropoffLocation {
//                    trip.eta = dpLoc.eta
//                    destination.trip = trip
//                }
//            }
//        } else if segue.identifier == "goStraightToActiveTripVCSegue" {
//            if let destination = segue.destination as? ActiveTripViewController {
//                if let trip = self.confirmedTrip {
//                    destination.trip = trip
//                }
//            }
//        }
//    }
    
    @IBAction func didTapOrderLemonade(_ sender: UIButton) {
        
        if let doLoc = self.dropoffLocation, let tripETA = doLoc.eta {
            let packageContent = "lemonade"
            let requestBody = NewTripRequest(pickupLocID: -1, dropoffLocID: doLoc.id, payloadContent: packageContent, eta: tripETA)
            
            self.orderDrinkButton.isEnabled = false
            self.orderDrinkButton.backgroundColor = UIColor.gray
            activityIndicator.startAnimating()
            
            TripManager.shared.createNewTrip(requestBody) { (userHasTrip, trip, goToActiveTripDirectly) in
                if userHasTrip == true {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    let alert = UIAlertController(title: "You have already ordered.", message: "As we are testing our system, we only allow one lemonade per person.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                        DispatchQueue.main.async {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                } else if trip != nil {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    let segueID = goToActiveTripDirectly ? "goStraightToActiveTripVCSegue" : "queuedTripSegue"
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.performSegue(withIdentifier: segueID, sender: self)
                    }
                } else {
                    print("Error creating trip")
                }
            }
        }
    }
}
