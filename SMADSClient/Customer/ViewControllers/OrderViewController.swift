//
//  OrderViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

enum OrderTableCellType {
    case pickup, dropoff
}

class OrderViewController : UIViewController {
    
    @IBOutlet var orderCollectionView: UICollectionView!
    @IBOutlet var orderPaginationControl: UIPageControl!
    
    var pickupLocations: [ServiceLocation] = []
    var dropoffLocations: [ServiceLocation] = []
    let numberOfPages = 4
    var pickupLocation: ServiceLocation?
    var dropoffLocation: ServiceLocation?
    var payloadName: String?
    var summaryCell: OrderSummaryCollectionViewCell?
    var confirmedTrip: Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Your Order"
        setupCollectionView()
        loadLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetSelections()
        
    }
    
    func resetSelections(){
        pickupLocation = nil
        dropoffLocation = nil
        payloadName = nil
        confirmedTrip = nil
        let indexPath = IndexPath(row: 0, section: 1)
        orderCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        orderCollectionView.isPagingEnabled = true
        orderCollectionView.setCollectionViewLayout(layout, animated: true)
        orderCollectionView.delegate = self
        orderCollectionView.dataSource = self
        orderPaginationControl.numberOfPages = numberOfPages
        orderCollectionView.showsVerticalScrollIndicator = false
        orderCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func loadLocations () {
        let slService = ServiceLocationService()
        slService.getServiceLocations(nil, false) { locs in
            if let locs = locs {
                self.pickupLocations = locs
                DispatchQueue.main.async {
                    if let cell = self.orderCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? OrderTableCollectionViewCell {
                        cell.locations = locs
                        cell.locationsTable.reloadData()
                    }
                }
            }
        }
        
        slService.getServiceLocations(nil, false) { locs in
            if let locs = locs {
                self.dropoffLocations = locs
                DispatchQueue.main.async {
                    if let cell = self.orderCollectionView.cellForItem(at: IndexPath(row: 2, section: 0)) as? OrderTableCollectionViewCell {
                        cell.locations = locs
                        cell.locationsTable.reloadData()
                    }
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestedTriptoMap"{
            if let destination = segue.destination as? ActiveTripViewController {
                if let trip = self.confirmedTrip {
                    destination.trip = trip
                    if let assignedSpot = trip.assignedSpot {
                        destination.spotName = assignedSpot.name
                    }
                }
            }
        }
    }
}

extension OrderViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.orderCollectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch(indexPath.row){
        case 0:
            return generatePickupCell(collectionView, for: indexPath)
        case 1:
            return generatePackageCell(collectionView, for: indexPath)
        case 2:
            return generateDropoffCell(collectionView, for: indexPath)
        case 3:
            return generateSummaryCell(collectionView, for: indexPath)
        default:
            return generateSummaryCell(collectionView, for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.orderPaginationControl.currentPage = indexPath.row
    }
    
    func generatePickupCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "orderTable", for: indexPath) as! OrderTableCollectionViewCell
        cell.setupCell(title: "Select your pick up location", type: .pickup, locations: pickupLocations)
        cell.delegate = self
        return cell
    }
    
    func generatePackageCell(_ collectionView: UICollectionView, for indexPath: IndexPath)-> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "packageView", for: indexPath) as! OrderPackageCollectionViewCell
        cell.delegate = self
        return cell
    }
    func generateDropoffCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "orderTable", for: indexPath) as! OrderTableCollectionViewCell
        if let pcLoc = self.pickupLocation
        {
            var i = 0
            for location in dropoffLocations{
                if location.locationName == pcLoc.locationName{
                    dropoffLocations.remove(at: i)
                    break
                }
                i += 1
            }
        }
        cell.setupCell(title: "Select your drop off location", type: .dropoff, locations: dropoffLocations)
        cell.delegate = self
        return cell
    }
    func generateSummaryCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "orderSummary", for: indexPath) as! OrderSummaryCollectionViewCell
        cell.delegate = self
        cell.setupCell()
        if let puLoc = pickupLocation, let doLoc = dropoffLocation, let packageContent = payloadName {
            cell.updateCell(pickupLocation: puLoc, dropoffLocation: doLoc, packageContent: packageContent)
        }
        summaryCell = cell
        return cell
    }
    
    @IBAction func prepareForUnwind(segue:UIStoryboardSegue)
    {
        
    }
}

extension OrderViewController: OrderTableViewDelegate {
    func didConfirmRequest() {
        if let puLoc = pickupLocation, let doLoc = dropoffLocation, let packageContent = payloadName, let tripETA = doLoc.eta {
            let requestBody = NewTripRequest(pickupLocID: puLoc.id, dropoffLocID: doLoc.id, payloadContent: packageContent, eta: tripETA)
            let slService = TripService()
            slService.createNewTrip(requestBody) { newTripRequest in
                if let tripRequest = newTripRequest {
                    if tripRequest.userHasTrip {
                        let alert = UIAlertController(title: "You have already ordered.", message: "As we are testing our system, we only allow one lemonade per person.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                            DispatchQueue.main.async {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                    } else if let trip = tripRequest.trip {
                        self.confirmedTrip = trip
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "tripIsNowActiveSegue", sender: self)
                        }
                    } else {
                        print("Error creating trip")
                    }
                }
            }
        }
    }
    
    func didAddPayloadDescription(_ payloadName: String) {
        self.payloadName = payloadName
        scrollToNextCell()
    }
        
    func didSelectLocation(_ location: ServiceLocation, type: OrderTableCellType) {
        if type == .pickup {
            pickupLocation = location
        } else if type == .dropoff {
            dropoffLocation = location
        }
        scrollToNextCell()
    }
    
    func scrollToNextCell() {
        let indexPaths = self.orderCollectionView.indexPathsForVisibleItems
        if indexPaths.count > 0 {
            let indexPath = indexPaths[0]
            if indexPath.row < numberOfPages {
                let newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                orderCollectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
                if newIndexPath.row == 3, let summaryCell = summaryCell, let puLoc = pickupLocation, let doLoc = dropoffLocation, let packageContent = payloadName {
                    summaryCell.updateCell(pickupLocation: puLoc, dropoffLocation: doLoc, packageContent: packageContent)
                }
            }
        }
    }
}
