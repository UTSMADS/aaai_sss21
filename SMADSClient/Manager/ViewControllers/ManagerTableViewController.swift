//
//  ManagerTableViewController.swift
//  SMADS Manager
//
//  Created by Asha Jain on 10/14/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class ManagerTableViewController: UITableViewController {
    
    let managerSerivce = ManagerService()
    
    var managers: [Manager] = [Manager]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllManagers()
        refreshControl?.addTarget(self, action: #selector(getAllManagers), for: UIControl.Event.valueChanged)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc func getAllManagers() {
        managerSerivce.getAllManagers { (managers) in
            if let managers = managers {
                self.managers = managers
            }
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @IBAction func didTapAddManager(_ sender: Any) {
        let ac = UIAlertController(title: "Add a new authorized manager", message: "This has to be a @gmail.com email address.", preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let managerEmailAddressTextField = ac.textFields![0]
            if let managerEmailAddress = managerEmailAddressTextField.text {
                let newManager = Manager(emailAddress: managerEmailAddress)
                self.managerSerivce.add(manager: newManager) { (newManager: Manager?) in
                    if let newManager = newManager {
                        self.getAllManagers()
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(ac, animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return managers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "managerCell") as! ManagerTableViewCell
        let manager = managers[indexPath.row]
        cell.managerEmailAddress = manager.emailAddress
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            managerSerivce.deleteManager(managers[indexPath.row]) { successfullyDeleted in
                if successfullyDeleted {
                    DispatchQueue.main.async {
                        self.managers.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
}
