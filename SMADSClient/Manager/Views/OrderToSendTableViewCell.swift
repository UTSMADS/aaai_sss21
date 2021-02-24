//
//  OrderToSendTableViewCell.swift
//  SMADS Manager
//
//  Created by Asha Jain on 10/7/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import UIKit

enum OrderCellType {
    case toBeCompleted
    case active
}

class OrderToSendTableViewCell: UITableViewCell {

    static let reuseIdentifier = "orderToSendCell"
    var delegate: OrderToSendDelegate?
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var orderDestination: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var orderPlacedAtLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var trip: Trip? {
        didSet {
            if let trip = trip {
                let dateUtil = DateUtil()
                orderDestination.text = getMainLabelText(trip: trip)
                var customerNameLabelText = trip.tripStatus.rawValue
                if let username = trip.username {
                    customerNameLabelText += " - \(username)"
                }
                customerNameLabel.text = customerNameLabelText
                if let eta = trip.eta {
                    orderPlacedAtLabel.text = trip.startTime == nil ? "" : "Placed at \(dateUtil.parseDateStringForTime(dateString: trip.startTime!)), ETA: \(eta) mins"
                } else {
                    orderPlacedAtLabel.text = trip.startTime == nil ? "" : "Placed at \(dateUtil.parseDateStringForTime(dateString: trip.startTime!))"
                }
            }
        }
    }
    
    var type: OrderCellType! {
        didSet {
            var buttonTitle: String
            switch type {
            case .toBeCompleted:
                buttonTitle = "SEND"
            case .active:
                buttonTitle = "SEND HOME"
            case .none:
                buttonTitle = ""
            }
            sendButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var shouldShowSendButton: Bool? {
        didSet {
            guard shouldShowSendButton != nil else { return }
            sendButton.isHidden = !shouldShowSendButton!
            sendButton.isUserInteractionEnabled = shouldShowSendButton!
            activityIndicator.isHidden = true
        }
    }
    
    @IBAction func didTapSend(_ sender: UIButton) {
        if let trip = trip, let delegate = delegate {
            delegate.didTapSend(for: trip, type: type, on: self)
        }
    }
    
    func getMainLabelText(trip: Trip) -> String {
        var result = ""
        if let dropoffLocationAcronym = trip.dropoffLocation.acronym {
            result = dropoffLocationAcronym
            if let spot = trip.assignedSpot {
                result += " - \(spot.name)"
            }
        }
        return result
    }
    
    func showSpinner() {
        sendButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideSpinner() {
        activityIndicator.stopAnimating()
        sendButton.isHidden = false
        activityIndicator.isHidden = true
    }
}

protocol OrderToSendDelegate {
    func didTapSend(for trip: Trip, type: OrderCellType, on cell: OrderToSendTableViewCell)
}
