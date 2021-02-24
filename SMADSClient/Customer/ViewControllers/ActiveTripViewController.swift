//
//  ActiveTripViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 6/17/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class ActiveTripViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var spotStatusLabel: UILabel!
    @IBOutlet var spotETALabel: UILabel!
    @IBOutlet weak var recenterButton: UIButton!
    
    let defaultCenterLatitude = 30.2895659
    let defaultCenterLongitude = -97.739267
    var spotAnnotation: CustomAnnotation?
    let spotPinReuseIdentifier = "spotPin"
    let defaultPinIdentifier = "mappin"
    let customMarkerView = "marker"
    var spotLocation: CLLocationCoordinate2D?
    var locationManager: CLLocationManager!
    var spotName : String = ""
    var polyline: MKPolyline?
    var spot:Spot? = nil
    var drawingTimer: Timer?
    
    var timer: Timer?
    var spotService: SpotService!
    
    var eta:Int = 0
    
    var trip : Trip? {
        didSet {
            DispatchQueue.main.async {
                self.loadViewIfNeeded()
                if let settedTrip = self.trip {
                    self.spot = settedTrip.assignedSpot
                    self.setupView(for: settedTrip)
                    if let tripeta = settedTrip.eta{
                        self.eta = tripeta
                        let etaString = self.calculateETA(self.eta * 60)
                        self.spotETALabel.text = etaString
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true

        TripManager.shared.getTripIfNeeded { trip in
            self.trip = trip
            if let t = trip, t.waypoints == nil || t.waypoints!.isEmpty {
                TripManager.shared.getTripIfNeeded { trip in
                    self.trip = trip
                    if let t = trip, t.waypoints == nil || t.waypoints!.isEmpty {
                        TripManager.shared.getTripIfNeeded { trip in
                            self.trip = trip
                            if let t = trip, t.waypoints == nil || t.waypoints!.isEmpty {
                                self.trip = trip
                            }
                        }
                    }
                }
            }
        }
        mapView.delegate = self
        mapView.register(SpotAnnotationView.self, forAnnotationViewWithReuseIdentifier: spotPinReuseIdentifier)
        mapView.register(ServiceLocationMarkerView.self, forAnnotationViewWithReuseIdentifier: customMarkerView)
        addMapRecenterButton()
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getSpotUpdatedCondition), userInfo: nil, repeats: true)
        
        self.spotService = SpotService()
        
        // Register for foreground/background notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.mapView.showsUserLocation = true
    }
    
    func calculateETA(_ travelTime: Int?) -> String {
        let currentTime = Date()
        if let time = travelTime {
            let eta = currentTime.addingTimeInterval(Double(time * 60))
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            return "\(dateFormatter.string(from: eta))"
        } else {
            return "---"
        }
    }
    
    func setupView(for trip: Trip) {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
        }
        
        spotStatusLabel.text = "Your \(trip.payloadContent) is enroute"
        
        if let arrivalTime = trip.eta {
            let eta = calculateETA(arrivalTime * 60)
            spotETALabel.text = "\(eta) ETA"
        } else {
            spotETALabel.text = "---"
        }
        navigationItem.title = "Thanks for ordering!"
        navigationController?.navigationBar.prefersLargeTitles = true
        mapView.removeAnnotations(mapView.annotations)
        updateMap(with: trip)
    }
    
    //    func startListeningForSpotCondition() {
    //        if let trip = trip, let spot = spot {
    //            let topic = "spotCondition/\(spot.manufacturerID)/trip/\(trip.id)"
    //            socketManager.subscribe(to: topic) { response in
    //                if let response = response {
    //                    do {
    //                        if let data = response.data(using: .utf8) {
    //                            let spotCondition = try JSONDecoder().decode(SpotConditionResponse.self, from: data)
    //                            self.spot?.chargeLevel = spotCondition.chargeLevel
    //                            self.spot?.currentLatitude = spotCondition.updatedSpotLatitude
    //                            self.spot?.currentLongitude = spotCondition.updatedSpotLongitude
    //                            self.spot?.status = spotCondition.spotStatus
    //                            self.spot?.heading = spotCondition.heading
    //                            if let updatedSpot = self.spot {
    //                                self.updateSpotLocationOnMap(updatedSpot)
    //                            }
    //                        }
    //                    } catch {
    //                        print("Error decoding JSON \(Trip.self) in call to \(topic)")
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    //    func startListeningForSpotComplete() {
    //        if let trip = trip, let spot = spot {
    //            let topic = "trip/\(trip.id)/complete"
    //            socketManager.subscribe(to: topic) { resp in
    //                print("Received trip complete for trip \(trip.id)")
    //                socketManager.unsubscribe(from: topic)
    //                socketManager.unsubscribe(from: "spotCondition/\(spot.manufacturerID)/trip/\(trip.id)")
    //                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
    //                    self.performSegue(withIdentifier: "confirmPickupSegue", sender: self)
    //                }
    //            }
    //        }
    //    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let confirmPickupVC = segue.destination as? ConfirmPickupViewController {
//            confirmPickupVC.trip = trip
//        }
//    }
    
    func updateSpotLocationOnMap(_ spot: Spot) {
        if self.spotAnnotation != nil {
            self.spotLocation = CLLocationCoordinate2D(latitude: spot.currentLatitude, longitude: spot.currentLongitude)
            
            DispatchQueue.main.async {
                if let spotAnnotationView = self.spotAnnotation!.view as? SpotAnnotationView {
                    UIView.animate(withDuration: 5, animations: {
                        if spot.heading != 0 {
                            spotAnnotationView.transform = CGAffineTransform(rotationAngle: CGFloat(spot.heading + Double.pi/2))
                        }
                        self.spotAnnotation!.coordinate = self.spotLocation!
                    })
                } else {
                    print("No Spot Annotation View")
                }
            }
        }
    }
    
    func updateMap(with trip: Trip) {
        if let assignedSpot = trip.assignedSpot {
            let latitudes = [trip.pickupLocation.latitude, trip.dropoffLocation.latitude]
            let longitudes = [trip.pickupLocation.longitude, trip.dropoffLocation.longitude]
            var index: Int = 0
            var annotationsToAdd = [CustomAnnotation]()
            
            for lat in latitudes{
                let annotation : CustomAnnotation
                
                if (index == 0) {
                    annotation = CustomAnnotation(title: "Pickup", locationName:   "\(trip.pickupLocation.locationName)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: longitudes[index]), type: .pickup)
                    
                } else {
                    annotation = CustomAnnotation(title: "Dropoff", locationName:   "\(trip.dropoffLocation.locationName)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: longitudes[index]), type: .dropoff)
                }
                
                if annotation.coordinate.latitude != 0.0 && annotation.coordinate.longitude != 0.0 {
                    annotationsToAdd.append(annotation)
                }
                index += 1
            }
            spotLocation = CLLocationCoordinate2D(latitude: assignedSpot.currentLatitude, longitude: assignedSpot.currentLongitude)
            let spotAnnotation = CustomAnnotation(title : assignedSpot.name, locationName: "\(assignedSpot.status)", coordinate: spotLocation!, type: .robot)
            
            if spotAnnotation.coordinate.latitude != 0.0 && spotAnnotation.coordinate.longitude != 0.0 {
                self.spotAnnotation = spotAnnotation
                annotationsToAdd.append(spotAnnotation)
            }
            
            let centerLocation = averageCoordinate()
            let puLoc = CLLocation(latitude: trip.pickupLocation.latitude, longitude: trip.pickupLocation.longitude)
            let doLoc = CLLocation(latitude: trip.dropoffLocation.latitude, longitude: trip.dropoffLocation.longitude)
            let distance = puLoc.distance(from: doLoc)
            let radius = 1.5 * distance
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotationsToAdd)
                self.mapView.centerToLocation(CLLocation.init(latitude: centerLocation.latitude, longitude: centerLocation.longitude), regionRadius: radius)
            }
            createPolyline()
        }
    }
    
    func createPolyline() {
        var route: [CLLocationCoordinate2D] = []
        if let activeTrip = self.trip {
            if let waypoints = activeTrip.waypoints {
                for point in waypoints {
                    route.append(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
                }
            }
        }
        addPolyLineToMap(route: route)
    }
    
    func addPolyLineToMap(route: [CLLocationCoordinate2D]) {
        let finalPolyline = MKPolyline(coordinates: route, count: route.count)
        self.mapView.addOverlay(finalPolyline, level: .aboveRoads)
        
        //        animate(route: route, duration: 1)
    }
    
    func animate(route: [CLLocationCoordinate2D], duration: TimeInterval) {
        guard route.count > 0 else { return }
        var currentStep = 1
        let totalSteps = route.count
        let stepDrawDuration = duration/TimeInterval(totalSteps)
        var previousSegment: MKPolyline?
        
        drawingTimer = Timer.scheduledTimer(withTimeInterval: stepDrawDuration, repeats: true) { [weak self] timer in
            guard let self = self else {
                // Invalidate animation if we can't retain self
                timer.invalidate()
                
                return
            }
            
            if let previous = previousSegment {
                // Remove last drawn segment if needed.
                self.mapView.removeOverlay(previous)
                previousSegment = nil
            }
            
            guard currentStep < totalSteps else {
                // If this is the last animation step...
                let finalPolyline = MKPolyline(coordinates: route, count: route.count)
                self.mapView.addOverlay(finalPolyline, level: .aboveRoads)
                // Assign the final polyline instance to the class property.
                self.polyline = finalPolyline
                timer.invalidate()
                
                return
            }
            
            // Animation step.
            // The current segment to draw consists of a coordinate array from 0 to the 'currentStep' taken from the route.
            let subCoordinates = Array(route.prefix(upTo: currentStep))
            let currentSegment = MKPolyline(coordinates: subCoordinates, count: subCoordinates.count)
            self.mapView.addOverlay(currentSegment)
            
            previousSegment = currentSegment
            currentStep += 1
        }
    }
    
    func calculateETA (_ timeToArrive: Int) -> (String) {
        let currentTime = Date()
        
        let eta = currentTime.addingTimeInterval(Double(timeToArrive))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return "\(dateFormatter.string(from: eta))"
    }
    
    func averageCoordinate () -> CLLocationCoordinate2D {
        var sumLatitude :Double = 0
        var sumLongitude:Double = 0
        var totalNum: Double = 0
        
        if let trip = trip, let waypoints = trip.waypoints {
            for waypoint in waypoints {
                sumLatitude += waypoint.latitude
                sumLongitude += waypoint.longitude
                totalNum += 1
            }
            sumLatitude += trip.pickupLocation.latitude + trip.dropoffLocation.latitude
            sumLongitude += trip.pickupLocation.longitude + trip.dropoffLocation.longitude
            totalNum += 2
            
        }
        
        if totalNum == 0 {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        } else {
            var averageLatitude = sumLatitude / totalNum
            var averageLongitude = sumLongitude / totalNum
            if (averageLatitude == 0.0 && averageLongitude == 0.0) {
                averageLongitude = defaultCenterLongitude
                averageLatitude = defaultCenterLatitude
            }
            return CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
        }
    }
    
    func addMapRecenterButton(){
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

// MARK: - MapView Delegate
extension ActiveTripViewController: MKMapViewDelegate {
    
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
                view.frame.size = CGSize(width: 30, height: 40)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            customAnnotation.view = view
            return view
        } else {
            var view = ServiceLocationMarkerView()
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: customMarkerView) as? ServiceLocationMarkerView {
                annotationView.annotation = annotation
                view = annotationView
                view.frame.size = CGSize(width: 60, height: 60)
            } else {
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
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard (view.annotation as? CustomAnnotation) != nil else {
            return
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    @objc func getSpotUpdatedCondition() {
        if let trip = TripManager.shared.currentTrip, let spot = trip.assignedSpot {
            spotService.getUpdatedSpotCondition(spot.manufacturerID) { resp in
                if let spotCondition = resp {
                    self.spot?.chargeLevel = spotCondition.chargeLevel
                    self.spot?.currentLatitude = spotCondition.updatedSpotLatitude
                    self.spot?.currentLongitude = spotCondition.updatedSpotLongitude
                    self.spot?.status = spotCondition.spotStatus
                    self.spot?.heading = spotCondition.heading
                    if self.spot != nil {
                        self.updateSpotLocationOnMap(self.spot!)
                    }
                    if self.spot?.status == .dropoff {
                        TripManager.shared.currentTrip?.assignedSpot = self.spot
                        self.timer?.invalidate()
                        self.timer = nil
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "confirmPickupSegue", sender: self)
                        }
                    }
                }
            }
        } else {
            print("getSpotUpdatedCondition - Current trip is nil or assigned spot is nil")
        }
    }
}

extension ActiveTripViewController {
    @objc func appMovedToForeground() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getSpotUpdatedCondition), userInfo: nil, repeats: true)
    }
    
    @objc func appMovedToBackground() {
        timer?.invalidate()
        timer = nil
    }
}
