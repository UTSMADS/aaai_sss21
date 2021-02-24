//
//  SpotDetailsViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 6/16/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SpotDetailsViewController: UIViewController {
    
    @IBOutlet var navTitle: UINavigationItem!
    @IBOutlet var detailsTableView: UITableView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var noTripsLabel: UILabel!
    
    var trips: [Trip] = []
    var spot: Spot? = nil
    var displayedAnnotations: [CustomAnnotation] = []
    let serviceLocationMarkerID = "serviceLocationMarker"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        setupView()
        mapView.delegate = self 
        mapView.register(ServiceLocationMarkerView.self, forAnnotationViewWithReuseIdentifier: serviceLocationMarkerID)
    }
    
    func setupView(){
        if let spot = spot {
            navTitle.title = "\(spot.name) Trips"
            
            let spotService = SpotService()
            spotService.getAllTrips(spot.manufacturerID) { (trips) in
                if let trips = trips {
                    self.trips = trips
                    DispatchQueue.main.async {
                        if self.trips.count == 0{
                            self.noTripsLabel.text = "No trips yet for \(spot.name)"
                            self.noTripsLabel.isHidden = false
                            self.detailsTableView.isHidden = true
                        }else{
                            self.detailsTableView.reloadData()
                            
                        }
                        self.navTitle.title = "\(spot.name): \(trips.count) \(trips.count == 1 ? "Trip" : "Trips")"
                        
                    }
                }
            }
        }
        let initialLocation = CLLocation(latitude: defaultCenterLatitude, longitude: defaultCenterLongitude)
        mapView.centerToLocation(initialLocation)
    }
}

extension SpotDetailsViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spotDetailsTableViewCell") as! SpotDetailsTableViewCell
        let tableTrip = trips[indexPath.row]
        cell.trip = tableTrip
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrip = trips[indexPath.row]
        var annotationsToDisplay: [CustomAnnotation] = []
        
        let puAnnotation = CustomAnnotation(title: "Pickup", locationName: selectedTrip.pickupLocation.locationName, coordinate: CLLocationCoordinate2D(latitude: selectedTrip.pickupLocation.latitude, longitude: selectedTrip.pickupLocation.longitude), type: .pickup)
        annotationsToDisplay.append(puAnnotation)
        
        let doAnnotation = CustomAnnotation(title: "Dropoff", locationName: selectedTrip.dropoffLocation.locationName, coordinate: CLLocationCoordinate2D(latitude: selectedTrip.dropoffLocation.latitude, longitude: selectedTrip.dropoffLocation.longitude), type: .dropoff)
        annotationsToDisplay.append(doAnnotation)
        
        if #available(iOS 13.4, *) {
            let centerLocation = CLLocation(coordinate: getCenterLocation([puAnnotation.coordinate, doAnnotation.coordinate]), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, courseAccuracy: 0, speed: 0, speedAccuracy: 0, timestamp: Date())
            let pickupLocation = MKMapPoint(puAnnotation.coordinate)
            let dropoffLocation = MKMapPoint(doAnnotation.coordinate)
            let distanceBetweenLocations = pickupLocation.distance(to: dropoffLocation)
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.displayedAnnotations)
                self.mapView.addAnnotations(annotationsToDisplay)
                self.mapView.centerToLocation(centerLocation, regionRadius: distanceBetweenLocations)
                group.leave()
            }
            
            group.notify(queue: .main) {
                self.displayedAnnotations = annotationsToDisplay
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
extension SpotDetailsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is CustomAnnotation else {return nil}
        
        var view = ServiceLocationMarkerView()
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: serviceLocationMarkerID) as? ServiceLocationMarkerView{
            annotationView.annotation = annotation
            view = annotationView
            view.frame.size = CGSize(width: 60, height: 60)
        } else {
            view = ServiceLocationMarkerView(annotation: annotation, reuseIdentifier: serviceLocationMarkerID)
            view.canShowCallout = false
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.frame.size = CGSize(width: 30, height: 40)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}




func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    guard let _ = view.annotation as? CustomAnnotation else {
        return
    }
    
    print("Callout Tapped")
}
