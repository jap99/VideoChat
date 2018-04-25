//
//  FriendsVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/24/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

class FriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tv: UITableView!
    
    var friendObjects: [Friend] = [] // our friend objects
    
    var friends:  [BackendlessUser] = [] // our backendless users
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredFriends = [BackendlessUser]
    
    let dataStore = backendless!.data.of(Friend.ofClass()) // accesses our Friend table that will be in Backendless
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
 
    // MARK: IBActions
    
    @IBAction func addFriendsBarButton_Pressed (_ sender: AnyObject) {
        
    }

}
