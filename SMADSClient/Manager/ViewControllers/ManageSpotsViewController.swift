//
//  ManageSpotsViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 6/15/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ManageSpotsViewController: UIViewController{
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var spotTableView: UITableView!
    @IBOutlet weak var recenterButton: UIButton!
    var spots : [Spot] = []
    var annotations :[MKPointAnnotation] = []
    let spotPinReuseIdentifier = "spotPin"
    let customMarkerView = "marker"

    override func viewDidLoad() {
        super.viewDidLoad()
        spotTableView.delegate = self
        spotTableView.dataSource = self
        mapView.register(SpotAnnotationView.self, forAnnotationViewWithReuseIdentifier: spotPinReuseIdentifier)
        mapView.delegate = self
        setupView()
        addMapRecenterButton()
    }
    
    func setupView() {
        loadSpots()
        let initialLocation = CLLocation(latitude: defaultCenterLatitude, longitude: defaultCenterLongitude)
        mapView.centerToLocation(initialLocation)
    }
    
    func updateSpotTableView(){
        DispatchQueue.main.async {
            self.spotTableView.reloadData()
        }
    }
    
    func loadSpots() {
        let spotSerivce = SpotService ()
        spotSerivce.getAllSpots { (spots) in
            if let spots = spots {
                self.spots = spots
                self.updateSpotTableView()
                self.updateMapView()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let spotDetailsVC = segue.destination as? SpotDetailsViewController
        {
            if let indexPath = spotTableView.indexPathForSelectedRow {
                spotDetailsVC.spot = spots[indexPath.row]
                spotTableView.deselectRow(at: indexPath, animated: true)
            }
        } else if let addSpotVC = segue.destination as? NewSpotViewController {
            addSpotVC.spotCreationDelegate = self
        }
    }
    
    func updateMapView() {
        let annotationsToRemove = annotations
        let centerLocation = averageCoordinate()
        let radius = CLLocationDistance(exactly: 1500.0)
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(annotationsToRemove)
            self.annotations.removeAll();
            for spot in self.spots{
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: spot.currentLatitude, longitude: spot.currentLongitude)
                annotation.title = "\(spot.name)"
                annotation.subtitle = "\(spot.manufacturerID) - \(spot.chargeLevel)%"
                self.annotations.append(annotation)
            }
            self.mapView.addAnnotations(self.annotations)
            self.mapView.centerToLocation(CLLocation.init(latitude: centerLocation.latitude, longitude: centerLocation.longitude), regionRadius: radius!)
        }
    }
    
    func averageCoordinate () -> CLLocationCoordinate2D {
        var coordinates: [CLLocationCoordinate2D] = []
        for spot in spots{
            coordinates.append(CLLocationCoordinate2D(latitude: spot.currentLatitude, longitude: spot.currentLongitude))
        }
        return getCenterLocation(coordinates)
    }
    
    @IBAction func didTapLogout(_ sender: UIBarButtonItem) {
        let authenticationService = AuthenticationService()
        authenticationService.logout()
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
    
    @IBAction func didTapReloadSpots(_ sender: Any) {
        loadSpots()
    }
}

// MARK: - Table View Delegate and Data Source
extension ManageSpotsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpotStatusCell") as! SpotTableViewCell
        let spot = spots[indexPath.row]
        cell.spot = spot
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("deleting at row \(indexPath.row)")
            let spotService = SpotService()
            let spot = spots[indexPath.row]
            spotService.deleteSpot(spotNumber: spot.manufacturerID) { (success) in
                if let success = success {
                    if success {
                        self.spots.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                            if indexPath.row < self.annotations.count {
                                self.mapView.removeAnnotation(self.annotations.remove(at: indexPath.row))
                            }
                        }
                    } else {
                        let alertViewController = UIAlertController(title: "Oops. There was a problem.", message: "Please try again later.", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default)
                        alertViewController.addAction(OKAction)
                        DispatchQueue.main.async {
                            self.present(alertViewController, animated: true)
                            
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Spot Creation Confirmation Delegate
extension ManageSpotsViewController: SpotCreationConfirmationDelegate {
    func didAddSpot(_ spot: Spot) {
        spots.append(spot)
        let ip = IndexPath(row: spots.count - 1, section: 0)
        spotTableView.insertRows(at: [ip], with: .automatic)
        updateMapView()
    }
}

// MARK: - MapView Delegate
extension ManageSpotsViewController: MKMapViewDelegate {
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
}
