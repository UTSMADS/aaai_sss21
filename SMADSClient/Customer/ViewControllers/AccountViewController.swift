//
//  AccountViewController.swift
//  Smds_app
//
//  Created by Asha Jain on 7/21/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import UIKit

class AccountViewController: UIViewController{
    
    @IBOutlet var scrollVIew: UIScrollView!
    
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var seeAllrRecentOrdersButton: UIButton!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var noRecentOrdersLabel: UILabel!
    @IBOutlet var recentOrdersCollectionView: UICollectionView!
    
    @IBOutlet var zzzImageView: UIImageView!
    let numberOfPagesForCollectionView = 5
    var recentOrderSummaryCell : RecentOrderSummaryCollectionViewCell?
    var user : User?{
        didSet{
            if let user = user{
                if let firstName = user.firstName, let lastName = user.lastName, let username = user.username{
                    let name = "\(firstName) \(lastName)"
                    let username = "\(username)"
                    DispatchQueue.main.async {
                        self.nameLabel.text = name
                        self.usernameLabel.text = username
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.nameLabel.text = "---"
                        self.usernameLabel.text = "---"
                    }
                }
            }
            
        }
    }
    var recentOrders: [Trip]? {
        didSet {
            setupCollectionView()
        }
    }
    
    var selectedTripForDetails: Trip?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        scrollVIew.delegate = self
        self.logoutButton.layer.cornerRadius = 8
        self.logoutButton.layer.borderColor = UIColor(named: "tint")?.cgColor
        self.logoutButton.layer.borderWidth = 1
        getRecentTrips()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func setupView()
    {
        let userService = UserService()
        userService.getUserInfo { (verifiedUser) in
            
            if let user = verifiedUser{
                self.user = user
                
            }
        }
    }
    
    func getRecentTrips()
    {
        let tripService = TripService()
        tripService.getAllTrips { (allOrders) in
            if let orders = allOrders{
                if orders.count == 0{
                    DispatchQueue.main.async {
                        self.noRecentOrdersLabel.text = "There are no recent orders. Place an order using the order tab."
                        self.noRecentOrdersLabel.isHidden = false
                        self.seeAllrRecentOrdersButton.isHidden = true
                        self.recentOrdersCollectionView.isHidden = true
                        self.zzzImageView.isHidden = false
                    }
                } else {
                    if orders.count < self.numberOfPagesForCollectionView
                    {
                        self.recentOrders = orders
                    } else {
                        var orderList = [Trip]()
                        for i in 0...self.numberOfPagesForCollectionView-1{
                            orderList.append(orders[i])
                        }
                        self.recentOrders = orderList
                    }
                }
            }
        }
    }
    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        DispatchQueue.main.async {
            self.recentOrdersCollectionView.isPagingEnabled = true
            self.recentOrdersCollectionView.setCollectionViewLayout(layout, animated: true)
            self.recentOrdersCollectionView.delegate = self
            self.recentOrdersCollectionView.dataSource = self
            self.recentOrdersCollectionView.showsVerticalScrollIndicator = false
            self.recentOrdersCollectionView.showsHorizontalScrollIndicator = true
            self.recentOrdersCollectionView.reloadData()
        }
    }

    @IBAction func didTapSeeAllOrdersButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            if let tbController = self.tabBarController{
                self.tabBarController?.selectedViewController = tbController.viewControllers?[1]
                if let vc = self.tabBarController?.selectedViewController as? UINavigationController {
                    vc.popViewController(animated: false)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "accountSettingSegue" {
            if let destination = segue.destination as? AccountSettingViewController{
                if let currentUser = self.user{
                    destination.delegate = self
                    destination.user = currentUser
                }
                
            }
        } else if segue.identifier == "showOrderDetailsSegue" {
            if let destination = segue.destination as? UserHistoryDetailsViewController, let trip = self.selectedTripForDetails {
                destination.trip = trip
            }
        }
    }
    
    @IBAction func didTapEditProfile(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "accountSettingSegue", sender: self)
        }
    }
    
    @IBAction func didTapLogOut(_ sender: UIButton) {
        let authenticationService = AuthenticationService()
        authenticationService.logout()
        
        if let authorizeVC = self.storyboard?.instantiateViewController(withIdentifier: "authorizeRootNavigationController") as? UINavigationController {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            authorizeVC.modalPresentationStyle = .fullScreen
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromLeft
            view.window!.layer.add(transition, forKey: kCATransition)
            self.present(authorizeVC, animated: false, completion: nil)
        }
    }
    
    @IBAction func unwindToMyAccountFromEditAccount(_ unwindSegue: UIStoryboardSegue) {
    }
}
//MARK: - Collection View Delegate
extension AccountViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let recentOrders = recentOrders {
            return min(recentOrders.count, numberOfPagesForCollectionView)
        } else {
            return numberOfPagesForCollectionView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return generateRecentOrderSummaryCell(collectionView, for: indexPath)
    }
    
    func generateRecentOrderSummaryCell (_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentOrderSummaryCell", for: indexPath) as! RecentOrderSummaryCollectionViewCell
        cell.delegate = self
        cell.backgroundColor = .white
        if let cellTrip = recentOrders?[indexPath.row]{
            cell.setupCell(cellTrip)
        }
        cell.layer.cornerRadius = 8
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedTripForDetails = self.recentOrders?[indexPath.row]
        self.performSegue(withIdentifier: "showOrderDetailsSegue", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let _: CGFloat = 64
        
        let cellWidth: CGFloat = getCellWidth(collectionView)
        let cellHeight: CGFloat = collectionView.frame.height - 20
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func getCellWidth(_ collectionView: UICollectionView) -> CGFloat {
        return collectionView.frame.width * 0.9
    }
    
    func getInsetSize(_ collectionView: UICollectionView) -> CGFloat {
        return (collectionView.frame.width - getCellWidth(collectionView) + 40) / 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return getInsetSize(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insetSize = getInsetSize(collectionView)
        
        return UIEdgeInsets(top: 0, left: insetSize, bottom: 0, right: insetSize)
    }
}
extension AccountViewController: RecentOrderDelegate{
    
    func didTapReportAnIssue(_ trip: Trip)
    {
        print("Customer indicated issue with order for trip: \(trip)")
        
    }
}

extension AccountViewController: UserDetailsDelegate{
    func didUpdateUserInformation(user: User) {
        self.user = user
        
    }
    
    
}
extension AccountViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}
