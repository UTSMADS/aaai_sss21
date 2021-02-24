//
//  LemonadeDropoffViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 7/26/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class LemonadeDropoffViewController:UIViewController{
    
    @IBOutlet var lemonadeDropoffTableView: UITableView!
    var dropoffLocations: [ServiceLocation] = []
    var selectedDropoffLocation : ServiceLocation?
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    var confirmedTrip : Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        lemonadeDropoffTableView.delegate = self
        lemonadeDropoffTableView.dataSource = self
        loadLocations()
        loaderView.hidesWhenStopped = true
        loaderView.startAnimating()
    }
    
    func loadLocations () {
        let slService = ServiceLocationService()
        slService.getServiceLocations(nil, true) { locs in
            if let locs = locs {
                self.dropoffLocations = locs
                self.updateLemonadeDropoffTableView()
            }
        }
    }
    
    func updateLemonadeDropoffTableView(){
        DispatchQueue.main.async {
            self.loaderView.stopAnimating()
            self.lemonadeDropoffTableView.reloadData()
            self.lemonadeDropoffTableView.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lemonadeSummarySegue" {
            if let destination = segue.destination as? LemonadeOrderSummaryViewController {
                if let dropoffLoc = self.selectedDropoffLocation {
                    destination.dropoffLocation = dropoffLoc
                   
                }
            }
        }
    }
}

extension LemonadeDropoffViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dropoffLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lemonadeDropoffCell") as! LemonadeDropoffTableViewCell
        let loc = dropoffLocations[indexPath.row]
        cell.displayServiceLocation = loc
        cell.accessoryType = .disclosureIndicator;
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedDropoffLocation = dropoffLocations[indexPath.row]
         DispatchQueue.main.async {
                self.performSegue(withIdentifier: "lemonadeSummarySegue", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
   
    }
    
}

