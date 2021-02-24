//
//  NewSpotController.swift
//  Smds_app
//
//  Created by Asha Jain on 6/16/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class NewSpotViewController: UIViewController {
    
    @IBOutlet var newSpotPageControl: UIPageControl!
    @IBOutlet var newSpotCollectionView: UICollectionView!
    
    let numberOfPages = 3
    var summaryCell : NewSpotSummaryCollectionViewCell?
    var newSpotRequest: NewSpotRequest?
    var delegate: NewSpotDelegate?
    var robotName: String?
    var robotNumber: Int?
    var robotManufacturerID: Int?
    var robotPassword : String?
    var robotIPAddress: String?
    var spotCreationDelegate: SpotCreationConfirmationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetSelections()
        
    }
    func resetSelections(){
        robotName = nil
        robotNumber = nil
        robotManufacturerID = nil
        robotPassword = nil
        robotIPAddress = nil
        let indexPath = IndexPath(row: 0, section: 1)
        newSpotCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        newSpotCollectionView.isPagingEnabled = true
        newSpotCollectionView.setCollectionViewLayout(layout, animated: true)
        newSpotCollectionView.delegate = self
        newSpotCollectionView.dataSource = self
        newSpotPageControl.numberOfPages = numberOfPages
        newSpotCollectionView.showsVerticalScrollIndicator = false
        newSpotCollectionView.showsHorizontalScrollIndicator = false
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}

// MARK: - Collection View Stuff
extension NewSpotViewController: UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.newSpotCollectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch(indexPath.row){
        case 0:
            return generateBasicInfoCell(collectionView, for: indexPath)
        case 1:
            return generateTechnicalInfoCell(collectionView, for: indexPath)
        case 2:
            return generateSummaryCell(collectionView, for: indexPath)
            
        default:
            return generateSummaryCell(collectionView, for: indexPath)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.newSpotPageControl.currentPage = indexPath.row
    }
    
    func generateBasicInfoCell (_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "basicInfoCell", for: indexPath) as! NewSpotBasicInfoCollectionViewCell
        cell.delegate = self
        
        return cell
    }
    
    func generateTechnicalInfoCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "technicalInfoCell", for: indexPath) as! NewSpotTechnicalInfoCollectionViewCell
        cell.delegate = self
        return cell
        
    }
    func generateSummaryCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newRobotSummaryCell", for: indexPath) as! NewSpotSummaryCollectionViewCell
        cell.delegate = self
        cell.setupCell()
        if let name = robotName, let number = robotNumber, let manufacturerID = robotManufacturerID, let ipAddress = robotIPAddress {
            cell.updateCell(name: name, number: number, mID: manufacturerID, ip: ipAddress)
        }
        summaryCell = cell
        return cell
        
    }
    
}

// MARK: - New Spot Delegate
extension NewSpotViewController: NewSpotDelegate{
    
    func didAddManufacturerID(value: String) {
        self.robotManufacturerID = Int(value)
    }
    
    func didAddIpAddress(value: String) {
        self.robotIPAddress = value
    }
    
    func didAddPassword(value: String) {
        self.robotPassword = value
        scrollToCell(at: 2)
    }
    
    func didAddRobotName(value: String) {
        self.robotName = value
    }
    
    func didAddRobotNumber(value: String) {
        self.robotNumber = Int(value)
        scrollToCell(at: 1)
    }
    
    func didCreateNewSpot(){
        if let name = self.robotName, let id = self.robotNumber, let mId = self.robotManufacturerID, let password = self.robotPassword, let ipAddress = self.robotIPAddress{
            
            let spotService = SpotService()
            spotService.createNewSpot(spotName: name, spotNumber: id, manufacturerID: mId, password: password, ipAddress: ipAddress) { (spot) in
                DispatchQueue.main.async {
                    if let spot = spot {
                        self.spotCreationDelegate?.didAddSpot(spot)
                    }
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func scrollToCell(at index: Int) {
        if index < numberOfPages {
            let newIndexPath = IndexPath(row: index, section: 0)
            newSpotCollectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
            if newIndexPath.row == 2, let summaryCell = summaryCell, let name = self.robotName, let number = self.robotNumber, let mId = self.robotManufacturerID, let ipAddress = self.robotIPAddress  {
                summaryCell.updateCell(name: name, number: number, mID: mId,  ip: ipAddress)
            }
        }
    }
}


