//
//  SpotPointAnnotation.swift
//  Smds_app
//
//  Created by Asha Jain on 6/29/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import MapKit

enum AnnotationType {
    case robot
    case outofservice
    case pickup
    case dropoff
    case servicelocation
    case library
    case officebuilding
    case dorm
    case restaurant
    case other
    
}

class CustomAnnotation: NSObject, MKAnnotation {
    var image: UIImage
    var title: String?
    var locationName: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var subtitle: String? {
        return locationName
    }
    var view: MKAnnotationView?
    var markerTintColor : UIColor = .red
    var annotationType: AnnotationType
    var switchButton : UISwitch?
    
    init(title: String?, locationName: String?, coordinate: CLLocationCoordinate2D, type: AnnotationType, shouldShowSwitch: Bool = false) {
        if shouldShowSwitch{
            switchButton = UISwitch()
            
        }
        
        var optionalImage : UIImage?
        switch type {
        case .robot:
            optionalImage = UIImage(named: "spot")
             markerTintColor = UIColor(named: "MapAnnotation")!
        case .outofservice:
            optionalImage =  UIImage(systemName: "mappin")
            markerTintColor = UIColor(named: "MapAnnotation")!
        case .pickup:
            optionalImage =   UIImage(named: "default_building")
            markerTintColor = UIColor(named: "lemonade")!
        case .dropoff:
            optionalImage =  UIImage(named: "default_building")
            markerTintColor = UIColor(named: "MapAnnotation")!
        case .library:
            optionalImage =  UIImage(named: "library")
            markerTintColor = UIColor(named: "MapAnnotation")!
        case .officebuilding:
            optionalImage =  UIImage(named: "office")
            markerTintColor = UIColor(named: "MapAnnotation")!
        case .dorm:
            optionalImage =  UIImage(named: "dorm")
            markerTintColor = UIColor(named: "MapAnnotation")!
        case .restaurant:
            optionalImage =  UIImage(named: "restaurant")
            markerTintColor = UIColor(named: "MapAnnotation")!
        case .other:
            optionalImage =  UIImage(named: "default_building")
            markerTintColor = UIColor(named: "MapAnnotation")!
        case .servicelocation:
            optionalImage =  UIImage(named: "default_building")
            markerTintColor = UIColor(named: "MapAnnotation")!
        }
        self.annotationType = type
        
        if let image = optionalImage {
            self.image = image
        }else{
            self.image = UIImage(named: "spot")!
        }
        
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
}
