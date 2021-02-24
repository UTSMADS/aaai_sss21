//
//  LocationSearchTable.swift
//  Smds_app
//
//  Created by William Kwon on 8/2/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class LocationSearchTable: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet weak var BarsSearchNoResultsLabel: UILabel!
    var mapView: MKMapView? = nil
        var matchingItems = [MKAnnotation]()
        var handleMapSearchDelegate:HandleMapSearch? = nil
        var  allServiceLocations: [ServiceLocation] = []
        func updateSearchResults(for searchController: UISearchController) {
            
            matchingItems = []
            guard let searchBarText = searchController.searchBar.text else { return }
            
           matchingItems = self.mapView!.annotations.filter { annotation -> Bool in
            if annotation.title!?.range(of: searchBarText, options: .caseInsensitive) != nil {
                       return true
                   }

            if annotation.subtitle!?.range(of: searchBarText, options: .caseInsensitive) != nil {
                       return true
                   }

                   return false
               }
            /*
            matchingItems = allServiceLocations.filter({ $0.locationName.contains(searchBarText) })
            .map({
              let annotation = MKPointAnnotation()
              annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: $0.latitude)!, longitude: CLLocationDegrees(exactly: $0.longitude)!)
              annotation.title = $0.locationName
              annotation.subtitle = $0.locationType.rawValue
            return annotation})
 */
            self.tableView.reloadData()
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard matchingItems.count != 0 else {
                self.BarsSearchNoResultsLabel.isHidden = false
                return 0
            }
            self.BarsSearchNoResultsLabel.isHidden = true
            return matchingItems.count
        }
   
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            
            let selectedItem = matchingItems[indexPath.row]
            cell.textLabel?.text = selectedItem.title!
            cell.detailTextLabel?.text = selectedItem.subtitle!
            
            
            
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedItem = matchingItems[indexPath.row]
            handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
            dismiss(animated: true, completion: nil)
        }
        
        
    }
