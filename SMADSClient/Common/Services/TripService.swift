//
//  TripService.swift
//  Smds_app
//
//  Created by Asha Jain on 6/28/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

class TripService {
    
    func cancelTrip(_ cancelledTrip: Trip, completion: @escaping (Bool?) -> ()) {
        NetworkService.delete(path: "/requests/\(cancelledTrip.id)", completion)
    }
    
    func createNewTrip(_ trip: NewTripRequest, _ completion: @escaping (_ trip: NewRequestResponse?) -> ()) {
        NetworkService.post(path: "/requests/", body: trip, completion)
    }
    func getAllTrips(_ completion: @escaping ([Trip]?) -> ()) {
        NetworkService.get(path: "/users/trips") { (allTripsResponse: AllTripsResponse?) in
            if let trips = allTripsResponse {
                completion(trips.allTrips)
            } else {
                completion(nil)
            }
        }
    }
    func completeTrip(_ completedTrip: Trip,  completion: @escaping (Bool?) -> () ){
        NetworkService.put(path: "/requests/\(completedTrip.id)/complete", completion)
       
    }
    
    func getCurrentTripForCustomer(completion: @escaping ((Trip?) -> ())) {
        NetworkService.get(path: "/users/activeTrip", completion)
    }
    
    func doesTripHaveRobot(_ tripID: Int, _ completion: @escaping (Trip?) -> ()) {
        NetworkService.get(path: "/requests/\(tripID)/hasRobot", completion)
    }

    func getTripsToComplete(completion: @escaping (TripsToCompleteResponse?) -> ()) {
        NetworkService.get(path: "/requests/notcomplete", completion)
    }
    
    func sendRobot(on trip: Trip, completion: @escaping(String?) -> ()) {
        NetworkService.post(path: "/requests/\(trip.id)/send") { (resp: String?) in
            completion(nil)
        }
    }
    
    func getTrip(id tripId: Int, completion: @escaping (Trip?) -> ()) {
        NetworkService.get(path: "/requests/\(tripId)/status", completion)
    }
    
    func notifyUserTripHasArrived(id tripId: Int, completion: @escaping () -> ()) {
        NetworkService.post(path: "/requests/\(tripId)/arrived") { (_: String?) in
            completion()
        }
    }
}
