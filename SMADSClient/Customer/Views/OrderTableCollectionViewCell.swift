//
//  OrderTableCollectionViewCell.swift
//  Smds_app
//
//  Created by Asha Jain on 6/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class OrderTableCollectionViewCell: UICollectionViewCell
{
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var locationsTable: UITableView!
    
    var locations: [ServiceLocation] = []
    var type: OrderTableCellType = .pickup
    var delegate: OrderTableViewDelegate?
    
    func setupCell(title: String, type: OrderTableCellType, locations: [ServiceLocation]) {
        self.type = type
        self.titleLabel.text = title
        self.locations = locations
        self.locationsTable.reloadData()
        self.locationsTable.dataSource = self
        self.locationsTable.delegate = self
    }
}

extension OrderTableCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceLocationTableViewCell") as! ServiceLocationTableViewCell
        let loc = locations[indexPath.row]
        cell.setupCell(name: loc.locationName, type: loc.locationType.rawValue)
        cell.accessoryType = .disclosureIndicator;
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let loc = self.locations[indexPath.row]
        delegate?.didSelectLocation(loc, type: self.type)
    }
}

