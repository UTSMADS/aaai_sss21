//
//  QueuedTripViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 9/1/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class QueuedTripViewController : UIViewController{
    
    @IBOutlet var etaLabel: UILabel!
    @IBOutlet var cancelTripButton: UIButton!
    
    var timer: Timer?
    
//    var tripWithRobot: Trip?
    var trip: Trip? {
        didSet {
            DispatchQueue.main.async {
                self.loadViewIfNeeded()
                if let queuedTrip = self.trip, let etaTime = queuedTrip.eta {
                    let etaString = self.calculateETA( etaTime * 60)
                    self.etaLabel.text = etaString
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        cancelTripButton.layer.cornerRadius = 8
        cancelTripButton.layer.borderColor = UIColor(named: "tint")?.cgColor
        cancelTripButton.layer.borderWidth = 1
        TripManager.shared.getTripIfNeeded { trip in
            self.trip = trip
        }
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getTripStatusUpdate), userInfo: nil, repeats: true)
        
        // Register for foreground/background notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
//    func setupTripUpdateListener() {
//        if let trip = trip {
//            let topic = "queuedTrip/\(trip.id)/send"
//            socketManager.subscribe(to: topic) { (stringBody) in
//                socketManager.unsubscribe(from: topic)
//                if let body = stringBody {
//                    do {
//                        if let data = body.data(using: .utf8) {
//                            let newTrip = try JSONDecoder().decode(Trip.self, from: data)
//                            self.tripWithRobot = newTrip
//                            DispatchQueue.main.async {
//                                self.performSegue(withIdentifier: "tripIsNowActiveSegue", sender: self)
//                            }
//                        }
//                    } catch {
//                        print("Error decoding JSON \(Trip.self) in call to \(topic)")
//                    }
//                }
//            }
//        }
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "tripIsNowActiveSegue" {
//            if let destination = segue.destination as? ActiveTripViewController, let trip = self.tripWithRobot {
//                DispatchQueue.main.async {
//                    destination.loadViewIfNeeded()
//                    destination.trip = trip
//                    if let eta = trip.eta{
//                        destination.eta = eta
//                    }
//                }
//            }
//        }
//    }
//
    @IBAction func didTapCancel(_ sender: UIButton) {
        TripManager.shared.cancelTrip { success in
            if !success {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                self.alertError()
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.async {
                    self.alertSuccess()
                }
            }
        }
    }
    
    private func alertError(){
        return self.alert(title: "Oops. There was an error in cancelling your request.", message: "Please try again later.")
    }
    
    private func alertSuccess() {
        return self.alertSuccessfulCancel(title:"Order cancelled", message: "Your order has successfully been cancelled")
    }
    
    private func alert(title: String, message: String) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "unwindToHomePage", sender: self)
        }))
        DispatchQueue.main.async {
            self.present(alertCtrl, animated: true, completion: nil)
        }
    }
    
    private func alertSuccessfulCancel(title:String, message: String) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "unwindToLemonadeRequestVC", sender: self)
        }))
        DispatchQueue.main.async {
            self.present(alertCtrl, animated: true, completion: nil)
        }
    }
    
    func calculateETA (_ timeToArrive: Int) -> (String) {
        let currentTime = Date()
        
        let eta = currentTime.addingTimeInterval(Double(timeToArrive))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        return "\(dateFormatter.string(from: eta))"
    }
    
    @objc func getTripStatusUpdate() {
        TripManager.shared.getTripStatus { tripStatus in
            if tripStatus == .enroute {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "tripIsNowActiveSegue", sender: self)
                }
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
}

extension QueuedTripViewController {
    @objc func appMovedToForeground() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getTripStatusUpdate), userInfo: nil, repeats: true)
    }
    
    @objc func appMovedToBackground() {
        timer?.invalidate()
        timer = nil
    }
}
