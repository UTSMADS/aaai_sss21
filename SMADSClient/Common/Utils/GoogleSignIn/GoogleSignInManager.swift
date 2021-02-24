//
//  GoogleSignInManager.swift
//
//  Created by Asha Jain on 10/6/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import GoogleSignIn

class GoogleSignInManager {
    static func setup() {
        GIDSignIn.sharedInstance().clientID = "751823011237-f986utomd6l8u4unk71cadsvrib6su51.apps.googleusercontent.com"
    }
}
