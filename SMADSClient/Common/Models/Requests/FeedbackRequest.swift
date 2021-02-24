//
//  Feedback.swift
//  Smds_app
//
//  Created by Asha Jain on 8/28/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct FeedbackRequest : Codable{
    let comment : String
    let issues : [Issue]?
    let tripID: Int
    let rating : Int?
}
