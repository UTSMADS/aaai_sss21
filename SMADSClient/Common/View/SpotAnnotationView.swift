//
//  SpotAnnotationView.swift
//  Smds_app
//
//  Created by Asha Jain on 6/30/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import MapKit

class SpotAnnotationView: MKAnnotationView{
    override var annotation: MKAnnotation? {
        willSet {
          // 1
          guard let spotPin = newValue as? CustomAnnotation else {
            return
          }
            canShowCallout = false
            calloutOffset = CGPoint(x: -5, y: 5)
            //rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            image = spotPin.image
          
      }
    }
}
