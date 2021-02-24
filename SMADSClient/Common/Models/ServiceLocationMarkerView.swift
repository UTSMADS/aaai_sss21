//
//  CustomMarkerAnnotation.swift
//  Smds_app
//
//  Created by Asha Jain on 6/30/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import MapKit

class ServiceLocationMarkerView: MKMarkerAnnotationView{
    override var annotation: MKAnnotation? {
        willSet {
            guard let customView = newValue as? CustomAnnotation else {
                return
            }
            canShowCallout = false
            calloutOffset = CGPoint(x: -5, y: 5)
            let switchButton = UISwitch()
            switchButton.isOn = true
            switchButton.onTintColor = .green
            switchButton.largeContentTitle = "Active"
            rightCalloutAccessoryView = switchButton
            markerTintColor = customView.markerTintColor
            glyphImage = customView.image
        }
    }
}
