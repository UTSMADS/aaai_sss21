//
//  UserService.swift
//  Smds_app
//
//  Created by Anurag Rajeev Patil on 13/08/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation


class UserService {
    
    func getUserInfo (completion: @escaping ((User?) -> ())) {
        NetworkService.get(path: "/users/userInfo", completion)
    }

    func putUpdateUserInfo (user: User, completion: @escaping ((User?) -> ())) {
        NetworkService.put(path: "/users/updateUserInfo", body: user, completion)
       
    }

}
