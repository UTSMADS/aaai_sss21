//
//  File.swift
//  Smds_app
//
//  Created by Asha Jain on 6/27/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
}

