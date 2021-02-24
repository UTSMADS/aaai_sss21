//
//  ServiceLocation.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct ServiceLocation: Codable {
    var id: Int
    var locationType : LocationType
    var locationName: String
    var latitude: Double
    var longitude: Double
    var active: Bool
    var home : Bool
    var numAvailableChargers : Int
    var acronym : String?
    var eta: Int?
}


enum LocationType: String, Codable {
    case officebuilding
    case library
    case restaurant
    case other
    case dorm
}
