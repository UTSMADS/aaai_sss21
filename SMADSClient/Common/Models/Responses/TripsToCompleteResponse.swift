//
//  TripsToCompleteResponse.swift
//  SMADS Manager
//
//  Created by Asha Jain on 10/8/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct TripsToCompleteResponse: Codable {
    var tripsToBeCompleted: [Trip]
    var activeTrips: [Trip]
    var returningHomeTrips: [Trip]
}
