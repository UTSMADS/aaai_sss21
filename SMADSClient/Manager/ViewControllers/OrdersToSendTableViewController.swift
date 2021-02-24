//
//  OrdersToSendTableViewController.swift
//  SMADS Manager
//
//  Created by Asha Jain on 10/7/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import UIKit

class OrdersToSendTableViewController: UITableViewController {
    
    let noOrdersCellReuseIdentifier = "noOrdersCell"
    var tripsToCompleted = [Trip]()
    var activeTrips = [Trip]()
    var returningHomeTrips = [Trip]()
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
//        startListeningForNewOrders()
        reloadOrders()
        self.tableView.allowsSelection = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.refreshControl?.addTarget(self, action: #selector(reloadOrders), for: UIControl.Event.valueChanged)
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(reloadOrders), userInfo: nil, repeats: true)

        // Register for foreground/background notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc func reloadOrders() {
        let tripService = TripService()
        tripService.getTripsToComplete { (tripsToCompleteResponse) in
            if let response = tripsToCompleteResponse {
                self.tripsToCompleted = response.tripsToBeCompleted
                self.activeTrips = response.activeTrips
                self.returningHomeTrips = response.returningHomeTrips
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if self.refreshControl?.isRefreshing ?? false {
                        self.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return max(1, tripsToCompleted.count)
        } else if section == 1 {
            return max(1, activeTrips.count)
        } else {
            return max(1, returningHomeTrips.count)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Trips to be sent"
        } else if section == 1 {
            return "Active Trips"
        } else if section == 2 {
            return "Returning Home"
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if (indexPath.section == 0 && tripsToCompleted.count == 0) || (indexPath.section == 1 && activeTrips.count == 0) || (indexPath.section == 2 && returningHomeTrips.count == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: noOrdersCellReuseIdentifier)!
        } else {
            let tripCell = tableView.dequeueReusableCell(withIdentifier: OrderToSendTableViewCell.reuseIdentifier) as! OrderToSendTableViewCell
            let tripForCell: Trip
            if indexPath.section == 0 {
                tripForCell = tripsToCompleted[indexPath.row]
            } else if indexPath.section == 1 {
                tripForCell = activeTrips[indexPath.row]
            } else {
                tripForCell = returningHomeTrips[indexPath.row]
            }
            tripCell.trip = tripForCell
            tripCell.delegate = self
            // Only show the send button for the first trip
            tripCell.shouldShowSendButton = (indexPath.section == 0 || indexPath.section == 1) && tripForCell.assignedSpot != nil //(indexPath.section == 0 && indexPath.row == 0 && tripForCell.assignedSpot != nil) || indexPath.section == 1
            tripCell.type = indexPath.section == 0 ? .toBeCompleted : indexPath.section == 1 ? .active : .none
            cell = tripCell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && !activeTrips.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let notifyAction = UIContextualAction(style: .normal, title: "Notify User") { (contextAction, view, completion) in
                let trip = self.activeTrips[indexPath.row]
                self.notifyUserTripHasArrived(trip: trip)
                completion(true)
            }
            notifyAction.image = UIImage(systemName: "bell.fill")
            notifyAction.backgroundColor = UIColor(named: "tint")
            return UISwipeActionsConfiguration(actions: [notifyAction])
        }
        return nil
    }
    
    func notifyUserTripHasArrived(trip: Trip) {
        let tripService = TripService()
        tripService.notifyUserTripHasArrived(id: trip.id) {
            let alert = UIAlertController(title: "Notification Sent!", message: "The user has been notified the robot had arrived.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
}

extension OrdersToSendTableViewController: OrderToSendDelegate {
    func didTapSend(for trip: Trip, type: OrderCellType, on cell: OrderToSendTableViewCell) {
        if let assignedSpot = trip.assignedSpot {
            if type == .toBeCompleted {
                let alertSheet = UIAlertController(title: "Please confirm the payload was loaded successfully on \(assignedSpot.name).", message: "The payload for this trip is \(trip.payloadContent). ", preferredStyle: .actionSheet)
                let confirmAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { action in
                    self.send(trip: trip)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alertSheet.addAction(confirmAction)
                alertSheet.addAction(cancelAction)
                DispatchQueue.main.async {
                    self.present(alertSheet, animated: true) {
                        cell.showSpinner()
                    }
                }
            } else {
                let alertSheet = UIAlertController(title: "Are you sure tou want to send \(assignedSpot.name) home?", message: "Only do this if the customer forgets to confirm pick up.", preferredStyle: .actionSheet)
                let confirmAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { action in
                    self.sendHome(trip: trip)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                    DispatchQueue.main.async {
                        cell.hideSpinner()
                    }
                }
                alertSheet.addAction(confirmAction)
                alertSheet.addAction(cancelAction)
                DispatchQueue.main.async {
                    cell.showSpinner()
                    self.present(alertSheet, animated: true)
                }
            }
        }
    }
    
    func send(trip: Trip) {
        let tripService = TripService()
        tripService.sendRobot(on: trip) { _ in
            self.reloadOrders()
        }
    }
    
    func sendHome(trip: Trip) {
        let tripService = TripService()
        tripService.completeTrip(trip) { _ in
            if let assignedSpot = trip.assignedSpot {
                let spotService = SpotService()
                spotService.sendSpotHome(spotID: assignedSpot.manufacturerID) { _ in
                    self.reloadOrders()
                }
            } else {
                let alert = UIAlertController(title: "Error sending spot home...", message: "There is no spot assigned to this trip.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okAction)
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension OrdersToSendTableViewController {
    @objc func appMovedToForeground() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(reloadOrders), userInfo: nil, repeats: true)
    }
    
    @objc func appMovedToBackground() {
        timer?.invalidate()
        timer = nil
    }
}
