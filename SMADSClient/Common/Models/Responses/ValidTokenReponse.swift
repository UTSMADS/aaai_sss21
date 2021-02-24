//
//  ValidTokenReponse.swift
//  Smds_app
//
//  Created by Asha Jain on 7/21/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct ValidTokenResponse: Codable{
    var customer: Bool?
    var activeTrip: Trip?
}
