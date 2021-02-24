//
//  ServiceLocationService.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

class ServiceLocationService{
    
    func getServiceLocations(_ type: LocationType?, _ shouldCalculateETA: Bool?, _ completion: @escaping ([ServiceLocation]?) -> ()) {
        var params: [String: String] = [:]
        if let type = type {
            params["type"] = type.rawValue
        }
        if let eta = shouldCalculateETA{
            params["shouldCalculateETA"] = eta.description
        }
        NetworkService.get(path: "/serviceLocations/", parameters: params) { (response: ServiceLocationResponse?) in
            if let response = response {
                completion(response.serviceLocationList)
            } else {
                completion(nil)
            }
        }
    }
    
    func createNewServiceLocation(latitude: Double, longitude: Double, locationName:String, locationType:LocationType,  completion: @escaping (ServiceLocation?) -> ()) {
        let locationRequestBody = NewServiceLocationRequest(latitude:latitude, longitude:longitude , locationName: locationName, locationType:locationType)
        NetworkService.post(path: "/serviceLocations/", body: locationRequestBody, completion)
    }
    
    func getServiceLocationWithLocationName(_ locationName: String, completion: @escaping ((ServiceLocation?) -> ()))
       {
           NetworkService.get(path: "/serviceLocations/\(locationName)", completion)
           
       }
    
  
}
