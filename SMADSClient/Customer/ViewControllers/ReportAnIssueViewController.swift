//
//  ReportAnIssueViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 8/28/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class ReportAnIssueViewController: UIViewController{
    
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var issueTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    var issueTrip : Trip?
    var comment: String = ""
    var selectedIssues = [Issue]()
    
    var issues : [Issue]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        issueTableView.delegate = self
        issueTableView.dataSource = self
        commentTextView.layer.cornerRadius = 8
        commentTextView.layer.borderColor = UIColor.systemGray.cgColor
        commentTextView.layer.borderWidth = 0.5
        commentTextView.delegate = self
        submitButton.layer.cornerRadius = 8
        setupview()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset

        let selectedRange = commentTextView.selectedRange
        commentTextView.scrollRangeToVisible(selectedRange)
    }
    
    func setupview(){
        let feedbackService = FeedbackService()
        feedbackService.getAllIssues() { issues in
            if let issues = issues{
                self.issues = issues
                DispatchQueue.main.async{
                    self.issueTableView.reloadData()
                }
            }
        }
    }
    
    
    @IBAction func didTapSubmitReport(_ sender: Any) {
        commentTextView.resignFirstResponder()
        
        if let trip = self.issueTrip {
            let feedback = FeedbackRequest(comment: comment, issues: selectedIssues, tripID: trip.id, rating: nil)
            let feedbackService = FeedbackService()
            feedbackService.sendFeedback(feedback) { (response) in
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
extension ReportAnIssueViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let issues = self.issues{
            return issues.count
            
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripIssueTableViewCell") as! TripIssueTableViewCell
        if let issues = self.issues{
            let label = issues[indexPath.row].issue
            cell.label = label
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let issues = self.issues {
            let tappedIssue = issues[indexPath.row]
            var i = -1
            for (index, issue) in selectedIssues.enumerated() {
                if issue.issue == tappedIssue.issue {
                    i = index
                    break
                }
            }
            if i != -1 {
                selectedIssues.remove(at: i)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .none
                }
            } else {
                selectedIssues.append(tappedIssue)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .checkmark
                }
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
extension ReportAnIssueViewController: UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        if let comment = commentTextView.text{
            self.comment = comment
        }
        commentTextView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            DispatchQueue.main.async {
                textView.resignFirstResponder()
            }
            return false
        }
        return true
    }
}
