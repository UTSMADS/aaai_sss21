//
//  AddTokenRequest.swift
//  SMADS Customer
//
//  Created by Asha Jain on 11/17/20.
//  Copyright © 2020 groupproject. All rights reserved.
//

import Foundation

struct AddTokenRequest: Codable {
    var token: String
    var manager: Bool
}
