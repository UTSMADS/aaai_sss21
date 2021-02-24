//
//  UserOrderMapFullScreenViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 9/3/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class UserOrderMapFullScreenViewController: UIViewController{
    
    @IBOutlet var mapview: MKMapView!
    let customMarkerView = "marker"
    
    var trip: Trip?
    {
        didSet{
            self.loadViewIfNeeded()
            updateMap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func updateMap(){
        if let trip = self.trip{
            let initialLocation = CLLocation(latitude: defaultCenterLatitude, longitude: defaultCenterLongitude)
            self.mapview.centerToLocation(initialLocation)
                           
            let poannotation = CustomAnnotation(title: "Pickup", locationName: trip.pickupLocation.locationName, coordinate: CLLocationCoordinate2D(latitude: trip.pickupLocation.latitude, longitude: trip.pickupLocation.longitude), type: .pickup)
                           
            let doannotation = CustomAnnotation(title: "Dropoff", locationName: trip.dropoffLocation.locationName, coordinate: CLLocationCoordinate2D(latitude: trip.dropoffLocation.latitude, longitude: trip.dropoffLocation.longitude), type: .dropoff)
                           
            self.mapview.addAnnotations([poannotation, doannotation])
        }
    
    }
}
extension UserOrderMapFullScreenViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let _ = annotation as? CustomAnnotation else {return nil}
        
        var view = ServiceLocationMarkerView()
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: customMarkerView) as? ServiceLocationMarkerView{
            annotationView.annotation = annotation
            view = annotationView
            view.frame.size = CGSize(width: 60, height: 60)
        }
        else{
            view = ServiceLocationMarkerView(
                annotation: annotation,
                reuseIdentifier: customMarkerView)
            view.canShowCallout = false
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.frame.size = CGSize(width: 30, height: 40)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let _ = view.annotation as? CustomAnnotation else {
            return
        }
        
        print("Callout Tapped")
        
    }
    
    
}
