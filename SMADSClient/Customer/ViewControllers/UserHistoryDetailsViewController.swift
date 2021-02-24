//
//  UserHistoryDetailsViewController.swift
//  Smds_app
//
//  Created by William Kwon on 7/1/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import UIKit
import MapKit

class UserHistoryDetailsViewController: UIViewController{
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var dropoffTimeLabel: UILabel!
    @IBOutlet var reportAnIssueButton: UIButton!
    @IBOutlet var orderTitleLabel: UILabel!
    @IBOutlet var tripStatusLabel: UILabel!
    @IBOutlet var deliveryDetailsUIView: UIView!
    @IBOutlet var orderUIView: UIView!
    @IBOutlet var orderDateLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var dropoffLocationLabel: UILabel!
    @IBOutlet var deliveredToLabel: UILabel!

    var isMapFullScreen = false
    var mapcenter = CGPoint()
    private var shadowLayer: CAShapeLayer?
    
    let customMarkerView = "marker"
    
    var eta:Int = 0 {
        didSet {
            let etaString = "ETA \(calculateETA(eta * 60))"
            dropoffTimeLabel.text = etaString
            
        }
    }
    
    var trip : Trip? {
        didSet {
            self.loadViewIfNeeded()
            if let settedTrip = trip {
                if settedTrip.spotManufacturerID == nil{
                    dropoffTimeLabel.isHidden = false
                    deliveredToLabel.text = "Will be delivered to:"
                    dropoffTimeLabel.text = "\( self.calculateETA(settedTrip.dropoffLocation.eta)) ETA"
                    dropoffLocationLabel.text = settedTrip.dropoffLocation.locationName
                    tripStatusLabel.text = "Status: \(settedTrip.tripStatus)"
                    let dateUtil = DateUtil()
                    if let startTimeString = settedTrip.startTime {
                        let startDate =  dateUtil.parseDateStringForCalendar(dateString: startTimeString)
                        orderDateLabel.text = startDate
                    } else {
                        orderDateLabel.text = "---"
                    }
                } else {
                    setupView()
                }
                self.orderTitleLabel.text = "Your Order (#\(settedTrip.id))"
                self.reportAnIssueButton.layer.cornerRadius = 8.0
                self.reportAnIssueButton.layer.borderColor = UIColor.darkGray.cgColor
                self.reportAnIssueButton.layer.borderWidth = 0.5
                
                if let t = trip {
                    let centerMapLocation = averageCoordinate(for: t)
                    mapView.centerToLocation(CLLocation(latitude: centerMapLocation.latitude, longitude: centerMapLocation.longitude))
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.register(ServiceLocationMarkerView.self, forAnnotationViewWithReuseIdentifier: customMarkerView)
        mapView.layer.cornerRadius = 8.0
        mapView.isUserInteractionEnabled = false
        
        scrollView.delegate = self
        
        orderUIView.layer.shadowColor = UIColor(named: "shadow")?.cgColor
        orderUIView.layer.shadowOpacity = 0.2
        orderUIView.layer.shadowOffset = .zero
        orderUIView.layer.shadowRadius = 20
        orderUIView.layer.cornerRadius = 8
        orderUIView.layer.shouldRasterize = true
        
        deliveryDetailsUIView.layer.shadowColor = UIColor(named: "shadow")?.cgColor
        deliveryDetailsUIView.layer.shadowOpacity = 0.2
        deliveryDetailsUIView.layer.shadowOffset = .zero
        deliveryDetailsUIView.layer.shadowRadius = 20
        deliveryDetailsUIView.layer.cornerRadius = 8
        deliveryDetailsUIView.layer.shouldRasterize = true
        
        navigationController?.navigationBar.prefersLargeTitles = true
        setupView()
    }
    
    func calculateETA(_ travelTime: Int?)-> String{
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

    func setupView() {
        let dateUtil = DateUtil()
        if let trip = self.trip{
            if let startTimeString = trip.startTime {
                let startDate =  dateUtil.parseDateStringForCalendar(dateString: startTimeString)
                self.navigationItem.title = "Thanks for ordering!"
                dropoffLocationLabel.text = trip.dropoffLocation.locationName
                orderDateLabel.text = startDate
                tripStatusLabel.text = "Status: \(trip.tripStatus)"
            }
            
            if let endTimeString = trip.endTime {
                let endDate = dateUtil.parseDateStringForTime(dateString: endTimeString)
                dropoffTimeLabel.text = endDate
            } else {
                dropoffTimeLabel.text = "---"
            }
            
            let initialLocation = CLLocation(latitude: defaultCenterLatitude, longitude: defaultCenterLongitude)
            mapView.centerToLocation(initialLocation)
            
            let poannotation = CustomAnnotation(title: "Pickup", locationName: trip.pickupLocation.locationName, coordinate: CLLocationCoordinate2D(latitude: trip.pickupLocation.latitude, longitude: trip.pickupLocation.longitude), type: .pickup)
            
            let doannotation = CustomAnnotation(title: "Dropoff", locationName: trip.dropoffLocation.locationName, coordinate: CLLocationCoordinate2D(latitude: trip.dropoffLocation.latitude, longitude: trip.dropoffLocation.longitude), type: .dropoff)
            
            mapView.addAnnotations([poannotation, doannotation])
            let mapTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
            self.mapView.addGestureRecognizer(mapTapGestureRecognizer)
        }
    }
    
    @objc func didTapMap() {
        if isMapFullScreen == false{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.mapcenter = self.mapView.center
                self.mapView.frame = CGRect(x: 0, y: 0, width: 130, height: 130)
                self.mapView.center = self.view.center
                self.mapView.transform = CGAffineTransform.identity
                self.mapView.layoutSubviews()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.mapView.transform = CGAffineTransform.identity
                self.mapView.center = self.mapcenter
                let height = 130
                let width = 130
                let mapViewFrame = CGRect(x: 0, y: 0, width: width, height: height)
                self.mapView.frame = mapViewFrame
                self.mapView.layoutSubviews()
            }, completion: nil)
        }
        self.isMapFullScreen = !self.isMapFullScreen
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reportAnIssueSegue" {
            if let destination = segue.destination as? ReportAnIssueViewController
            {
                destination.issueTrip = trip
            }
        }
        if segue.identifier == "showMapFullScreenSegue" {
            if let destination = segue.destination as? UserOrderMapFullScreenViewController{
                destination.trip = self.trip
            }
        }
    }
    
    @IBAction func reportAnIssueButton(_ sender: Any) {
        self.performSegue(withIdentifier: "reportAnIssueSegue", sender: self)
    }
}



extension UserHistoryDetailsViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let _ = annotation as? CustomAnnotation else {return nil}
        
        var view = ServiceLocationMarkerView()
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: customMarkerView) as? ServiceLocationMarkerView{
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let _ = view.annotation as? CustomAnnotation else {
            return
        }
        
        print("Callout Tapped")
        
    }
    
}
extension UserHistoryDetailsViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}

