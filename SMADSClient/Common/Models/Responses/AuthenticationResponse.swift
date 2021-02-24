//
//  AuthenticationResponse.swift
//  Smds_app
//
//  Created by Asha Jain on 6/24/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct AuthenticationResponse : Codable{
    var token: String?
    var isManager: Bool?
    var manager: Bool?
    var customerTrip: Trip?
}
