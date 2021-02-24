//
//  NewSpotRequest.swift
//  Smds_app
//
//  Created by Asha Jain on 6/16/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct NewSpotRequest: Codable {
    var name: String
    var spotId: Int
    var manufacturerID: Int;
    var password: String;
    var ipAddress: String;
}
