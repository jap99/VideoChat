//
//  ChooseUserVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/22/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import UIKit

class ChooseUserVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    let searchController = UISearchController(searchResultsController: nil)
    var users: [BackendlessUser] = []
    var filteredUsers: [BackendlessUser] = []
    
    @IBOutlet weak var tv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.delegate = self; tv.dataSource = self
        searchController.searchResultsUpdater = self // tells users when there's an update
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true // required for searchResultsController
        
        tv.tableHeaderView = searchController.searchBar
        
        loadUsers()
    }
    
    
 
    // MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell") as! FriendCell
        
        var friend: BackendlessUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            friend = filteredUsers[indexPath.row]
        } else {
            
            friend = users[indexPath.row]
        }
        cell.bindData(friend: friend)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return users.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // create a recent item each time
        let user: BackendlessUser
        
        // check if user searched for this user or chose it from user's array
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        startChat(user1: backendless!.userService.currentUser, user2: user)
    }
    
    // MARK: - LOAD USERS
    
    func loadUsers() {
        
        let whereClause = "objectId != '\(backendless!.userService.currentUser.objectId!)'"
        //let dataQuery = BackendlessDataQuery()
        let dataQuery = DataQueryBuilder()
     //   dataQuery?.setWhereClause(whereClause)
        dataQuery!.setWhereClause(whereClause)
        
        let dataStore = backendless!.persistenceService.of(BackendlessUser.ofClass())
        
        // now that we have dataStore we can do the query
        dataStore!.find(dataQuery, response: { (users) in
            
            self.users = users! as! [BackendlessUser]
            self.tv.reloadData()
            
        }) { fault in
            
            ProgressHUD.showError("Couldn't load users: \(fault!.detail)")
        }
    }
    
    // MARK: - SEARCH FUNCTIONS
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredUsers = users.filter { user in
            
            return user.name.lowercased.contains(searchText.lowercased())
        }
        tv.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
