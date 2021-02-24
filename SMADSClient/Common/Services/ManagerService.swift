//
//  ManagerService.swift
//  SMADS Manager
//
//  Created by Asha Jain on 10/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

class ManagerService {
    
    func getAllManagers(completion: @escaping ([Manager]?) -> ()) {
        NetworkService.get(path: "/managers/") { (managerResponse: AllManagersResponse?) in
            if let response = managerResponse {
                completion(response.allManagers)
            }
        }
    }
    
    func deleteManager(_ manager: Manager, completion: @escaping (Bool) -> ()) {
        let deleteRequest = DeleteManagerRequest(emailAddress: manager.emailAddress)
        NetworkService.delete(path: "/managers/", body: deleteRequest) { (response: DeleteManagerResponse?) in
            if let response = response {
                completion(response.successfullyDeleted)
            } else {
                completion(false)
            }
        }
    }
    
    func add(manager: Manager, completion: @escaping (Manager?) -> ()) {
        let newManagerRequest = NewManagerRequest(emailAddress: manager.emailAddress)
        NetworkService.post(path: "/managers/", body: newManagerRequest, completion)
    }
}
