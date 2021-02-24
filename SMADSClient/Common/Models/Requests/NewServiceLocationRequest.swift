//
//  NewLocationRequest.swift
//  Smds_app
//
//  Created by Anurag Rajeev Patil on 02/07/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct NewServiceLocationRequest: Codable {
    var latitude: Double
    var longitude: Double
    var locationName: String
    var locationType : LocationType
}

