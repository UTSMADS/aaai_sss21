//
//  Codable+Dictionary.swift
//  Smds_app
//
//  Created by Asha Jain on 6/24/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
