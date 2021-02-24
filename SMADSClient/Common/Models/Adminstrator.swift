//
//  Adminstrator.swift
//  Smds_app
//
//  Created by William Kwon on 6/24/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit
struct Administrator {
    let id: String
    let password: String
    let first_name: String
    let last_name: String
  
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case password = "password"
        case first_name = "first_name"
        case last_name = "last_name"
     
    }
    
  
}
extension Administrator {
    init(data: [String: String]) {
          self.id = data["id"]!
          self.password = data["password"]!
          self.first_name = data["first_name"]!
          self.last_name = data["last_name"]!
          
      
        
      }
}

extension Administrator : Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.password = try container.decode(String.self, forKey: .password)
        self.first_name = try container.decode(String.self, forKey: .first_name)
        self.last_name = try container.decode(String.self, forKey: .last_name)
      
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.password, forKey: .password)
        try container.encode(self.first_name, forKey: .first_name)
        try container.encode(self.last_name, forKey: .last_name)
    
    }
}
