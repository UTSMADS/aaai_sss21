//
//  File.swift
//  SMADS
//
//  Created by Asha Jain on 10/10/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

class StoreService {
    func getStoreDetails(completion: @escaping (Store?) -> ()) {
        NetworkService.get(path: "/stores/status") { (storeStatusResponse: StoreStatusResponse?) in
            if let resp = storeStatusResponse {
                completion(resp.store)
            }
        }
    }
    
    func updateStore(status open: Bool, completion: @escaping (Store?) -> ()) {
        NetworkService.post(path: "/stores/status", body: StoreStatusRequest(open: open)) { (storeStatusResponse: StoreStatusResponse?) in
            if let resp = storeStatusResponse {
                completion(resp.store)
            }
        }
    }
    
    func updateStore(description: String, completion: @escaping (Store?) -> ()) {
        NetworkService.post(path: "/stores/description", body: StoreDescriptionRequest(description: description)) { (storeStatusResponse: StoreStatusResponse?) in
            if let resp = storeStatusResponse {
                completion(resp.store)
            }
        }
    }
}
