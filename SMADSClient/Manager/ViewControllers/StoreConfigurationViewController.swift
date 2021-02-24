//
//  StoreConfigurationViewController.swift
//  SMADS Manager
//
//  Created by Asha Jain on 10/7/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import UIKit

class StoreConfigurationViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var storeStateSegmentControl: UISegmentedControl!
    var textInTextField: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        let storeService = StoreService()
        storeService.getStoreDetails { (storeResp) in
            if let store = storeResp {
                DispatchQueue.main.async {
                    self.textField.text = store.hoursDescription
                    self.storeStateSegmentControl.selectedSegmentIndex = store.open ? 0 : 1
                }
            }
        }
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func didChangeStoreState(_ control: UISegmentedControl) {
        var isOpen = false
        if control.selectedSegmentIndex == 0 {
            isOpen = true
        }
        let storeService = StoreService()
        storeService.updateStore(status: isOpen) { (storeResp) in
            if let store = storeResp, store.open == isOpen {
                self.showSuccessfulUpdateAlert()
            }
        }
    }
    
    func showSuccessfulUpdateAlert() {
        let alert = UIAlertController(title: "Store status was updated", message: "The store information was updated successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

extension StoreConfigurationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            textInTextField = textView.text
            let storeService = StoreService()
            storeService.updateStore(description: textView.text) { storeResp in
                if let store = storeResp, store.hoursDescription == textView.text {
                    self.showSuccessfulUpdateAlert()
                }
            }
            return false
        }
        return true
    }
}
