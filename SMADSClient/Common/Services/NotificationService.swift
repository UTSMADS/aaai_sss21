//
//  NotificationService.swift
//  SMADS Customer
//
//  Created by Asha Jain on 11/17/20.
//  Copyright © 2020 groupproject. All rights reserved.
//

import Foundation

class NotificationService {
    func saveTokenForUser(token: String, manager: Bool) {
        let addTokenRequest = AddTokenRequest(token: token, manager: manager)
        NetworkService.post(path: "/notifications/tokens", body: addTokenRequest) { (resp: SimpleSuccessResponse?) in
            if let resp = resp {
                print("Successfully registered token: \(resp.success)")
            }
        }
    }
}
