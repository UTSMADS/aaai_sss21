//
//  NewTripResponse.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

enum SpotStatus: String, Codable {
    case enroute, pickup, dropoff, charging, available, outofservice, returninghome, reconnectingToInternet, assignedTrip
}

enum TripStatus: String, Codable {
    case complete, requested, dropoff, returningHome, enroute, cancelled, processing
}

struct Trip: Codable {
    var id: Int
    var pickupLocation: ServiceLocation
    var dropoffLocation: ServiceLocation
    var tripStatus: TripStatus
    var startTime: String?
    var endTime: String?
    var payloadContent: String
    var assignedSpot: Spot?
    var active: Bool
    var spotManufacturerID: Int?
    var userID: Int
    var waypoints: [Waypoint]?
    var returningHome : Bool?
    var eta: Int?
    var username: String?
}
