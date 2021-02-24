//
//  SpotService.swift
//  Smds_app
//
//  Created by Asha Jain on 6/15/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

class SpotService {
    func getAllSpots(_ completion: @escaping ([Spot]?) -> ()) {
        NetworkService.get(path: "/spots/") { (allSpots: AllSpotResponse?) in
            if let allSpots = allSpots {
                completion(allSpots.spots)
            } else {
                completion(nil)
            }
        }
    }
    
    func createNewSpot(spotName: String, spotNumber: Int, manufacturerID: Int, password: String, ipAddress: String, completion: @escaping (Spot?) -> ()) {
        let spotRequestBody = NewSpotRequest(name: spotName, spotId: spotNumber, manufacturerID: manufacturerID, password: password, ipAddress: ipAddress)
        NetworkService.post(path: "/spots/", body: spotRequestBody, completion)
    }
    
    func deleteSpot(spotNumber: Int, completion: @escaping (Bool?) -> ()) {
        NetworkService.delete(path: "/spots/\(spotNumber)", completion)
    }
    
    func getAllTrips(_ databaseID: Int , _ completion: @escaping ([Trip]?) -> ()) {
        NetworkService.get(path: "/spots/\(databaseID)/trips") { (response: AllTripsResponse?) in
            if let response = response {
                completion(response.allTrips)
            } else {
                completion(nil)
            }
        }
    }
    
    func getUpdatedSpotCondition(_ databaseID: Int, _ completion: @escaping (SpotConditionResponse?) -> ()){
        NetworkService.get(path: "/spots/\(databaseID)/statusUpdate", completion)
    }
    
    func sendSpotHome(spotID: Int, _ completion: @escaping (Bool?) -> ()){
        NetworkService.post(path: "/spots/\(spotID)/returnHome", completion)
    }
}
