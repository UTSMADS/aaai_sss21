//
//  MapUtils.swift
//  Smds_app
//
//  Created by Asha Jain on 6/27/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import MapKit

let defaultCenterLatitude = 30.2895659
let defaultCenterLongitude = -97.739267

func getCenterLocation(_ coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
    var sumLatitude :Double = 0
    var sumLongitude:Double = 0
    var totalNum: Double = 0.0
    for coordinate in coordinates {
        if(coordinate.longitude != 0.0 && coordinate.latitude != 0.0){
            sumLatitude += coordinate.latitude
            sumLongitude += coordinate.longitude
            totalNum += 1.0
        }
    }
    var averageLatitude = sumLatitude / totalNum
    var averageLongitude = sumLongitude / totalNum
    if (averageLatitude == 0.0 && averageLongitude == 0.0 || totalNum == 0) {
        averageLongitude = defaultCenterLongitude
        averageLatitude = defaultCenterLatitude
    }
    return CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
}

func averageCoordinate(for trip: Trip) -> CLLocationCoordinate2D {
    var sumLatitude :Double = 0
    var sumLongitude:Double = 0
    var totalNum: Double = 0
    
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
    
    var averageLatitude = sumLatitude / totalNum
    var averageLongitude = sumLongitude / totalNum
    if (averageLatitude == 0.0 && averageLongitude == 0.0) {
        averageLongitude = defaultCenterLongitude
        averageLatitude = defaultCenterLatitude
    }
    return CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
}
