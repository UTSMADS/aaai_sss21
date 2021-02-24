//
//  MapKitExtensions.swift
//  Smds_app
//
//  Created by Asha Jain on 6/27/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
