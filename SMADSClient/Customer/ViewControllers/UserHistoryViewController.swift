//
//  UserHistoryViewController.swift
//  Smds_app
//
//  Created by William Kwon on 7/1/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import UIKit

class UserHistoryViewController: UIViewController {
    
    @IBOutlet var zzzImage: UIImageView!
    @IBOutlet var addIconImage: UIImageView!
    @IBOutlet var addOrderLabel: UILabel!
    @IBOutlet var noOrdersYetLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView!
    var reloadButton: UIBarButtonItem!
    
    @IBOutlet var historyTableView: UITableView!
    var trips : [Trip] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Your Order History"
        historyTableView.delegate = self
        historyTableView.dataSource = self
        loadTrips()
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        reloadButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(didTapRefreshOrders))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTrips()
    }
    
    @objc func loadTrips() {
        let tripSerivce = TripService ()
        tripSerivce.getAllTrips { (trips) in
            if let trips = trips {
                self.trips = trips
                if trips.count > 0 {
                    self.updateHistoryTableView()
                } else {
                    self.enableNoTripYetComponents()
                }
            } else {
                self.enableNoTripYetComponents()
            }
            self.showButtonInsteadOfLoader()
        }
    }
    
    func enableNoTripYetComponents() {
        DispatchQueue.main.async {
            self.addIconImage.isHidden = false
            self.addOrderLabel.isHidden = false
            self.noOrdersYetLabel.isHidden = false
            self.zzzImage.isHidden = false
            self.historyTableView.isHidden = true
        }
    }
    
    func updateHistoryTableView(){
        DispatchQueue.main.async {
            self.historyTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let userHistoryDetailsVC = segue.destination as? UserHistoryDetailsViewController {
            if let indexPath = historyTableView.indexPathForSelectedRow {
                userHistoryDetailsVC.trip = trips[indexPath.row]
            }
        }
    }
    
    @IBAction func didTapRefreshOrders(_ sender: Any) {
        showLoaderInsteadOfButton()
        loadTrips()
    }
    
    func showLoaderInsteadOfButton() {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
            self.activityIndicator.startAnimating()
        }
    }
    
    func showButtonInsteadOfLoader() {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = self.reloadButton
            self.activityIndicator.startAnimating()
        }
    }
}

extension UserHistoryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userHistoryTableViewCell") as! UserHistoryTableViewCell
        let trip = trips[indexPath.row]
        cell.trip = trip
        return cell
    }
}

