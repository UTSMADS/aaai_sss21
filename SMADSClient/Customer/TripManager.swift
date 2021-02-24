//
//  TripManager.swift
//  SMADS Customer
//
//  Created by Asha Jain on 11/14/20.
//  Copyright © 2020 groupproject. All rights reserved.
//

import Foundation

class TripManager {
    static let shared = TripManager()
    
    var currentTrip: Trip?
//    private var trips: [Trip] = []
    private let tripService = TripService()
    
    func getTripIfNeeded(completion: @escaping (Trip?) -> ()) {
        if currentTrip == nil {
            tripService.getCurrentTripForCustomer { tripResponse in
                if let trip = tripResponse {
                    self.currentTrip = trip
                }
                completion(self.currentTrip)
            }
        } else {
            completion(currentTrip)
        }
    }
    
    func getTrip(completion: @escaping (Trip?) -> ()) {
        if let trip = currentTrip {
            tripService.getTrip(id: trip.id) { tripResponse in
                if let resp = tripResponse {
                    self.currentTrip = resp
                }
                completion(self.currentTrip)
            }
        } else {
            completion(nil)
        }
    }
    
    func getTripStatus(completion: @escaping (TripStatus?) -> ()) {
        getTrip { tripResponse in
            if let resp = tripResponse {
                completion(resp.tripStatus)
            } else {
                completion(nil)
            }
        }
    }
    
    func createNewTrip(_ newTripRequest: NewTripRequest, completion: @escaping (_ userHasTrip: Bool?, _ trip: Trip?, _ goToActiveTripDirectly: Bool) -> ()) {
        tripService.createNewTrip(newTripRequest) { response in
            if let response = response {
                if !response.userHasTrip {
                    self.currentTrip = response.trip
                    completion(response.userHasTrip, self.currentTrip, response.goToActiveTripDirectly)
                } else {
                    completion(response.userHasTrip, nil, false)
                }
            } else {
                completion(nil, nil, false)
            }
        }
    }
    
    func cancelTrip(completion: @escaping (Bool) -> ()) {
        if let trip = currentTrip {
            tripService.cancelTrip(trip) { success in
                if let success = success, success == true {
                    self.currentTrip = nil
                    return completion(true)
                } else {
                    return completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func completeTrip(completion: @escaping (Bool) -> ()) {
        if let trip = currentTrip {
            tripService.completeTrip(trip) { success in
                if let success = success, success == true {
                    self.currentTrip = nil
                    return completion(true)
                } else {
                    return completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
}
