//
//  Store.swift
//  SMADS
//
//  Created by Asha Jain on 10/10/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct Store: Codable {
    var id: Int
    var name: String
    var hoursDescription: String
    var open: Bool
}
