//
//  Spot.swift
//  Smds_app
//
//  Created by Asha Jain on 6/16/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct Spot: Codable {
    var id: Int
    var name: String
    var chargeLevel: Double
    var status: SpotStatus
    var currentLongitude: Double
    var currentLatitude: Double
    var active: Bool
    var manufacturerID: Int
    var ipAddress: String?
    var heading: Double
}

struct SpotLocation: Codable {
    var longitude: Double
    var latitude: Double
    var date: Date
}
