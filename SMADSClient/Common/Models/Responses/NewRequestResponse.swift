//
//  NewRequestResponse.swift
//  SMADS Customer
//
//  Created by Asha Jain on 10/8/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct NewRequestResponse: Codable {
    var trip: Trip?
    var userHasTrip: Bool
    var goToActiveTripDirectly: Bool
}
