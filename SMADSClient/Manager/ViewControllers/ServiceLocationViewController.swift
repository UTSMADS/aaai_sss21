//
//  ServiceLocationViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 6/23/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKAnnotation)
}

class ServiceLocationViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var recenterButton: UIButton!
    
    var allServiceLocations : [ServiceLocation] = []
    let defaultCenterLatitude = 30.2895659
    let defaultCenterLongitude = -97.739267
    let locationManager = CLLocationManager()
    let serviceLocationMarker = "marker"
    let radius = CLLocationDistance(exactly: 1500.0)
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var searchController:UISearchController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        mapView.register(ServiceLocationMarkerView.self, forAnnotationViewWithReuseIdentifier: serviceLocationMarker)
        setupView()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier:     "LocationSearchTable") as! LocationSearchTable
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as UISearchResultsUpdating
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.searchController = resultSearchController
        definesPresentationContext = true
        searchBar.delegate = self
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        addMapRecenterButton()
    }
    
    func setupView() {
        self.loadViewIfNeeded()
        self.navigationController?.title = "Locations"
        let slService = ServiceLocationService()
        slService.getServiceLocations(nil, false) { locations in
            if let locations = locations {
                self.allServiceLocations = locations
                self.updateMap()
            }
        }
        
        let center = self.averageCoordinate()
        
        self.mapView.centerToLocation(CLLocation.init(latitude: center.latitude, longitude: center.longitude), regionRadius: self.radius!)
        
    }
    
    func updateMap(){
        var annotations: [CustomAnnotation] = []
        for location in allServiceLocations {
            
            let type : AnnotationType
            
            
            switch location.locationType{
            case .dorm:
                type = AnnotationType.dorm
            case .officebuilding:
                type = AnnotationType.officebuilding
            case .library:
                type = AnnotationType.library
            case .restaurant:
                type = AnnotationType.restaurant
            case .other:
                type = AnnotationType.other
            }
            let annotation = CustomAnnotation(title: "\(location.locationName)", locationName: "\(location.locationType) " , coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), type: type)
            annotations.append(annotation)
        }
        let centerLocation = self.averageCoordinate()
        DispatchQueue.main.async {
            self.mapView.centerToLocation(CLLocation.init(latitude: centerLocation.latitude, longitude: centerLocation.longitude), regionRadius: self.radius!)
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func averageCoordinate () -> CLLocationCoordinate2D {
        var sumLatitude :Double = 0
        var sumLongitude:Double = 0
        var totalNum: Double = 0
        
        for location in allServiceLocations{
            if(location.latitude != 0.0 && location.longitude != 0.0){
                sumLatitude += location.latitude
                sumLongitude += location.longitude
                totalNum += 1.0
            }
        }
        
        var averageLatitude = sumLatitude / totalNum
        var averageLongitude = sumLongitude / totalNum
        if (averageLatitude == 0.0 || averageLongitude == 0.0 || totalNum == 0.0) {
            averageLongitude = defaultCenterLongitude
            averageLatitude = defaultCenterLatitude
        }
        return CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
    }
    
    func addMapRecenterButton(){
        //        let imageFilled = UIImage(named: "location.fill")
        //        self.recenterButton.setImage(imageFilled, for: .selected)
        self.recenterButton.layer.cornerRadius = 10
        self.recenterButton.addTarget(self, action: #selector(centerMapOnUserButtonClicked), for: .touchUpInside)
        
        self.mapView.addSubview(recenterButton)
        
    }
    
    
    @objc func centerMapOnUserButtonClicked() {
        let span = MKCoordinateSpan(latitudeDelta: 0.017, longitudeDelta: 0.017)
        let region = MKCoordinateRegion(center: averageCoordinate(), span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    
}
extension ServiceLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is CustomAnnotation else {return nil}
        
        var view = ServiceLocationMarkerView()
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: serviceLocationMarker) as? ServiceLocationMarkerView{
            annotationView.annotation = annotation
            view = annotationView
            view.image = (annotation as! CustomAnnotation).image
            print(view.image!)
            view.frame.size = CGSize(width: 60, height: 60)
            
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.frame.size = CGSize(width: 30, height: 40)
            
            let switchButton = UISwitch()
            switchButton.isOn = true
            switchButton.onTintColor = .green
            switchButton.largeContentTitle = "Active"
            view.rightCalloutAccessoryView = switchButton

        } else {
            view = ServiceLocationMarkerView(
                annotation: annotation,
                reuseIdentifier: serviceLocationMarker)
            view.canShowCallout = false
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.frame.size = CGSize(width: 30, height: 40)
            
            let switchButton = UISwitch()
            switchButton.isOn = true
            switchButton.onTintColor = .green
            switchButton.largeContentTitle = "Active"
            view.rightCalloutAccessoryView = switchButton
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard (view.annotation as? CustomAnnotation) != nil else {
            return
        }
        print("Callout Tapped")
    }
}

extension ServiceLocationViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKAnnotation) {
        let center = CLLocationCoordinate2D(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude )
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        self.mapView.setRegion(region, animated: true)
    }
}




// TODO - uncomment this to implement the search bar and get user gps location
//extension ViewController : CLLocationManagerDelegate {
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse {
//            locationManager.requestLocation()
//        }
//    }
//
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            print("location:: (location)")
//        }
//    }
//
//    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        print("error:: (error)")
//    }
//}
