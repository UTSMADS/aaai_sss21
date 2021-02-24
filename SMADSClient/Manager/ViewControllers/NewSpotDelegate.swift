//
//  NewSpotDelegate.swift
//  Smds_app
//
//  Created by Asha Jain on 6/16/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

protocol NewSpotDelegate {
    func didCreateNewSpot()
    func didAddManufacturerID(value: String)
    func didAddIpAddress(value: String)
    func didAddPassword(value: String)
    func didAddRobotName(value: String)
    func didAddRobotNumber(value:String)
}
