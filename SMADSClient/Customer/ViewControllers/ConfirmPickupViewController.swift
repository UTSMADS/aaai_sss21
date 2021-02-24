//
//  ConfirmPickupViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 7/6/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import MapKit
import Foundation
import UIKit
import CoreLocation

class ConfirmPickupViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var recenterButton: UIButton!
    let defaultCenterLatitude = 30.2895659
    let defaultCenterLongitude = -97.739267
    var spotAnnotation: CustomAnnotation?
    let spotPinReuseIdentifier = "spotPin"
    let customMarkerView = "marker"
    var spotLocation: CLLocationCoordinate2D?
    var locationManager: CLLocationManager!
    var spotName : String = ""
    var spot: Spot? = nil
    var previousTimeStamp = StatusTimestamp()
    
    var trip : Trip? {
        didSet {
            DispatchQueue.main.async {
                self.loadViewIfNeeded()
                if let trip = self.trip {
                    if let spot = trip.assignedSpot{
                        self.spot = spot
                    }
                    self.setupView(for: trip)
    //                getUpdatedConditionForSpot()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.title = ""
        TripManager.shared.getTripIfNeeded { trip in
            self.trip = trip
        }
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
        }
        self.locationManager.startUpdatingLocation()
        mapView.delegate = self
        mapView.register(SpotAnnotationView.self, forAnnotationViewWithReuseIdentifier: spotPinReuseIdentifier)
        mapView.register(ServiceLocationMarkerView.self, forAnnotationViewWithReuseIdentifier: customMarkerView)
        addMapRecenterButton()
        setupTripAutocloseListener()
        
        // Register for foreground/background notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
//    func getUpdatedConditionForSpot() {
//        if let spot = self.spot {
//            let spotService = SpotService()
//            spotService.getUpdatedSpotCondition(spot.manufacturerID) { (response) in
//                if let response = response, self.spot != nil {
//                    self.spot!.currentLatitude = response.updatedSpotLatitude
//                    self.spot!.currentLongitude = response.updatedSpotLongitude
//                    self.updateSpotLocationOnMap(self.spot!, animated: false)
//                }
//            }
//        }
//    }
    
    func setupTripAutocloseListener() {
        if let trip = trip {
            let topic = "queuedTrip/\(trip.id)/autoclose"
            socketManager.subscribe(to: topic) { _ in
                socketManager.unsubscribe(from: topic)
                self.navigationController?.popToRootViewController(animated: true)
                let alertCtrl = UIAlertController(title: "The robot returned home.", message: "You did not indicate picking up your lemonade in time. The robot returned home", preferredStyle: .alert)
                alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel))
                DispatchQueue.main.async {
                    self.present(alertCtrl, animated: true, completion: nil)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.mapView.showsUserLocation = true
    }
    
    func setupView(for trip: Trip) {
        if let trip = self.trip {
            if let spot = trip.assignedSpot{
                self.title = "\(spot.name) has arrived."
            }
        }
        self.confirmButton.layer.cornerRadius = 8
        self.confirmButton.layer.borderColor = UIColor(named: "tint")?.cgColor
        self.confirmButton.layer.borderWidth = 1
        
        let initialLocation = CLLocation(latitude: defaultCenterLatitude, longitude: defaultCenterLongitude)
        self.mapView.centerToLocation(initialLocation)
        updateMap(with: trip)
    }
    
//    func startListeningForSpotCondition() {
//        if let spot = spot, let trip = trip {
//            let topic = "spotCondition/\(spot.manufacturerID)/trip/\(trip.id)/confirmPickUp"
//            socketManager.subscribe(to: topic) { response in
//                socketManager.unsubscribe(from: topic)
//                if let response = response {
//                    do {
//                        if let data = response.data(using: .utf8) {
//                            let spotCondition = try JSONDecoder().decode(SpotConditionResponse.self, from: data)
//                            self.spot?.chargeLevel = spotCondition.chargeLevel
//                            self.spot?.currentLatitude = spotCondition.updatedSpotLatitude
//                            self.spot?.currentLongitude = spotCondition.updatedSpotLongitude
//                            self.spot?.status = spotCondition.spotStatus
//                            self.spot?.heading = spotCondition.heading
//
//                            if self.spot?.status == .dropoff {
//                                DispatchQueue.main.async {
//                                    self.performSegue(withIdentifier: "confirmPickupSegue", sender: self)
//                                }
//                            }
//                            self.updateSpotLocationOnMap(spot)
//                        }
//                    } catch {
//                        print("Error decoding JSON \(Trip.self) in call to \(topic)")
//                    }
//                }
//            }
//        }
//    }
    
    func updateSpotLocationOnMap(_ spot: Spot, animated: Bool = true) {
        if let spotAnnotation = self.spotAnnotation {
            self.spotLocation = CLLocationCoordinate2D(latitude: spot.currentLatitude, longitude: spot.currentLongitude)

            DispatchQueue.main.async {
                if let spotAnnotationView = spotAnnotation.view as? SpotAnnotationView {
                    UIView.animate(withDuration: animated ? 1 : 0, animations: {
                        spotAnnotationView.transform = CGAffineTransform(rotationAngle: CGFloat(spot.heading))
                        spotAnnotation.coordinate = self.spotLocation!
                    })
                }
                print("Moved Spot Location")
            }
        }
    }
    
    func updateMap(with trip: Trip) {
        if let assignedSpot = self.spot {
            let latitude = trip.dropoffLocation.latitude
            let longitude =  trip.dropoffLocation.longitude
            let annotation : CustomAnnotation
            
            annotation = CustomAnnotation(title: "Dropoff", locationName:   "\(trip.dropoffLocation.locationName)", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), type: .dropoff)
            
            if annotation.coordinate.latitude != 0.0 && annotation.coordinate.longitude != 0.0 {
                mapView.addAnnotation(annotation)
            }
            
            spotLocation = CLLocationCoordinate2D(latitude: assignedSpot.currentLatitude, longitude: assignedSpot.currentLongitude)
            let spotAnnotation = CustomAnnotation(title : assignedSpot.name, locationName: "\(assignedSpot.status)", coordinate: spotLocation!, type: .robot)
            
            if spotAnnotation.coordinate.latitude != 0.0 || spotAnnotation.coordinate.longitude != 0.0 {
                self.spotAnnotation = spotAnnotation
                mapView.addAnnotation(spotAnnotation)
            }
            
            let centerLocation = self.averageCoordinate()
            let radius = CLLocationDistance(exactly: 1500.0)
            DispatchQueue.main.async {
                self.mapView.centerToLocation(CLLocation.init(latitude: centerLocation.latitude, longitude: centerLocation.longitude), regionRadius: radius!)
            }
            createPolyline()
        }
    }
    
    func createPolyline() {
        let point1 = CLLocationCoordinate2DMake(30.28851, -97.73782); // Anna Hiss
        let point2 = CLLocationCoordinate2DMake(30.287834, -97.738270);
        let point3 = CLLocationCoordinate2DMake(30.287954, -97.739547);
        let point4 = CLLocationCoordinate2DMake(30.287463, -97.739386);
        let point5 = CLLocationCoordinate2DMake(30.286901, -97.739288); //Main Building location
        
        let points: [CLLocationCoordinate2D]
        points = [point1, point2, point3, point4, point5]
        
        let geodesic = MKGeodesicPolyline(coordinates: points, count: points.count)
        mapView.addOverlay(geodesic)
        
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region1 = MKCoordinateRegion(center: point1, span: span)
            self.mapView.setRegion(region1, animated: true)
        })
    }
    
    func averageCoordinate() -> CLLocationCoordinate2D {
        var sumLatitude :Double = 0
        var sumLongitude:Double = 0
        var totalNum: Double = 0
        
        if let trip = trip, let spot = trip.assignedSpot {
            if (spot.currentLatitude != 0.0 && spot.currentLongitude != 0.0) {
                sumLatitude += spot.currentLatitude
                sumLongitude += spot.currentLongitude
                totalNum += 1.0
            }
            if (trip.pickupLocation.latitude != 0.0 && trip.pickupLocation.longitude != 0.0) {
                sumLatitude += trip.pickupLocation.latitude
                sumLongitude += trip.pickupLocation.longitude
                totalNum += 1.0
            }
            
            if (trip.dropoffLocation.latitude != 0.0 && trip.dropoffLocation.longitude != 0.0) {
                sumLatitude += trip.dropoffLocation.latitude
                sumLongitude += trip.dropoffLocation.longitude
                totalNum += 1.0
            }
        }
        
        var averageLatitude = sumLatitude / totalNum
        var averageLongitude = sumLongitude / totalNum
        if (averageLatitude == 0.0 && averageLongitude == 0.0) {
            averageLongitude = defaultCenterLongitude
            averageLatitude = defaultCenterLatitude
        }
        return CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
    }
    
    func addMapRecenterButton() {
        self.recenterButton.layer.cornerRadius = 10
        self.recenterButton.addTarget(self, action: #selector(centerMapOnUserButtonClicked), for: .touchUpInside)
        self.mapView.addSubview(recenterButton)
    }
    
    @objc func centerMapOnUserButtonClicked() {
        let span = MKCoordinateSpan(latitudeDelta: 0.017, longitudeDelta: 0.017)
        let region = MKCoordinateRegion(center: averageCoordinate(), span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    private func alertConfirmPickup() {
        return self.alertPickup(title: "Thank you, again", message: "You confirmed that you picked up your order. See you again soon!")
    }
    
    private func alertPickup(title:String, message: String) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            DispatchQueue.main.async {
                if let tbController = self.tabBarController{
                    self.tabBarController?.selectedViewController = tbController.viewControllers?[1]
                    self.navigationController?.popToRootViewController(animated: false)
                }
            }
        }))
        DispatchQueue.main.async {
            self.present(alertCtrl, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapConfirmPickup(_ sender: UIButton) {
        let spotService = SpotService()
        DispatchQueue.main.async {
            sender.isEnabled = false
        }
        if let completedTrip = self.trip {
            TripManager.shared.completeTrip() { success in
                if !success {
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    print("Error in completing the trip")
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    print("Successfully completing the trip")
                }
                
                if let spotID = completedTrip.spotManufacturerID {
                    spotService.sendSpotHome(spotID: spotID) { success in
                        if let success = success {
                            if !success {
                                print("Error in sending the spot home")
                            } else {
                                print("Able to send spot home")
                                DispatchQueue.main.async {
                                    self.alertConfirmPickup()
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            sender.isEnabled = true
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        sender.isEnabled = true
                    }
                }
            }
        }
    }
}

extension ConfirmPickupViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let customAnnotation = annotation as? CustomAnnotation else { return nil }
        
        if customAnnotation.annotationType == .robot {
            var view = SpotAnnotationView()
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: spotPinReuseIdentifier) as? SpotAnnotationView {
                annotationView.annotation = annotation
                view = annotationView
                view.frame.size = CGSize(width: 60, height: 60)
            } else {
                view = SpotAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: spotPinReuseIdentifier)
                view.canShowCallout = false
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.frame.size = CGSize(width: 60, height: 60)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            customAnnotation.view = view
            return view
        } else {
            var view = ServiceLocationMarkerView()
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: customMarkerView) as? ServiceLocationMarkerView{
                annotationView.annotation = annotation
                view = annotationView
                view.frame.size = CGSize(width: 60, height: 60)
            } else {
                view = ServiceLocationMarkerView(annotation: annotation, reuseIdentifier: customMarkerView)
                view.canShowCallout = false
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.frame.size = CGSize(width: 30, height: 40)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            return view
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let _ = view.annotation as? CustomAnnotation else { return }
        print("Callout Tapped")
    }
}

extension ConfirmPickupViewController {
    @objc func appMovedToForeground() {
        TripManager.shared.getTripStatus { tripStatus in
            if tripStatus == .complete {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
