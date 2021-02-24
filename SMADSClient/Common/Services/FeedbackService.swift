//
//  FeedbackService.swift
//  Smds_app
//
//  Created by Asha Jain on 8/28/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

class FeedbackService{
    func getAllIssues(_ completion: @escaping ([Issue]?)->()){
        NetworkService.get(path: "/feedback/issues") { (issueResponse: IssuesResponse?) in
            if let response = issueResponse {
                completion(response.issues)

            }
        }
    }
    
    func sendFeedback(_ feedback: FeedbackRequest, _ completion: @escaping (FeedbackRequest?)->()){
        NetworkService.post(path: "/feedback", body: feedback, completion)
    }
}
