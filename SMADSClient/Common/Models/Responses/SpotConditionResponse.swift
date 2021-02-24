//
//  SpotConditionResponse.swift
//  Smds_app
//
//  Created by Asha Jain on 6/29/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

class SpotConditionResponse: Codable {
    var updatedSpotLatitude: Double
    var updatedSpotLongitude: Double
    var spotStatus: SpotStatus
    var chargeLevel: Double
    var heading: Double
}
