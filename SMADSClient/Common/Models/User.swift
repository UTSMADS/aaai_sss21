//
//  User.swift
//  Smds_app
//
//  Created by William Kwon on 6/24/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit
struct User: Codable {
    let id: Int
    var firstName: String?
    var lastName: String?
    var username: String?
    var active: Bool?
    var manager: Bool?
    

    }


struct UserDefaultConstants{
    static let userID = "userID"
}
