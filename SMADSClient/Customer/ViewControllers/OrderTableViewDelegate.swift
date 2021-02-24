//
//  OrderViewControllerDelegate.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

protocol OrderTableViewDelegate {
    func didSelectLocation(_ location: ServiceLocation, type: OrderTableCellType)
    func didAddPayloadDescription(_ payloadName: String)
    func didConfirmRequest()
}
