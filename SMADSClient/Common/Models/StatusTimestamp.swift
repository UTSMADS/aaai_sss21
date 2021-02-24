//
//  StatusTimestamp.swift
//  Smds_app
//
//  Created by Asha Jain on 8/21/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct StatusTimestamp: Codable{
    var seconds: Double
    var milliseconds: Double
    
    init() {
        self.seconds = -1
        self.milliseconds = -1
    }
}
