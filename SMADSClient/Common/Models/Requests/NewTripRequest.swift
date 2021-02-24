//
//  NewTripRequest.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct NewTripRequest: Codable {
    var pickupLocID: Int
    var dropoffLocID: Int
    var payloadContent: String
    var eta: Int
}
