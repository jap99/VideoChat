//
//  AddFriendVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/24/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

protocol AddFriendDelegate {
    
    func saveFriend(selectedFriend: BackendlessUser)
}


class AddFriendVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tv: UITableView!
    
    var users: [BackendlessUser] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUsers: [BackendlessUser] = [] // getting all the users of our app here
    
    var delegate: AddFriendDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUsers()
        
        searchController.searchResultsUpdater = self // our current view is one that will get our current search updates
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tv.tableHeaderView = searchController.searchBar // our tv's header is where our search bar will show
        searchController.searchBar.placeholder = "Search"
        
    }

    
    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredUsers.count // because while user's searching we're putting all the results in filteredUsers
        } else {
            
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell") as! FriendCell
        
        var user: BackendlessUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
           user = filteredUsers[indexPath.row]
        } else {
            
            user = users[indexPath.row]
        }
        
        cell.bindData(friend: user)
        
        return cell
    }
  
    
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user: BackendlessUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredUsers[indexPath.row]
        } else {
            
            user = users[indexPath.row]
        }
        
        // add user to friend's list
        
        // tell our delegate the view that will be our delegate to know we've chosen a user
        delegate.saveFriend(selectedFriend: user)
        
        // get back to friendsVC
        tv.deselectRow(at: indexPath, animated: true)
        self.navigationController!.popViewController(animated: true) 
    }
    
    
    
    // MARK: Load Users
    
    func loadUsers() {
        
        let whereClause = "objectId != '\(backendless!.userService.currentUser.objectId!)'" // gets all Id's that aren't equal to our current user id because we don't want to load him also
        let dataQuery = DataQueryBuilder()
        dataQuery!.setWhereClause(whereClause)
        
        let dataStore = backendless!.persistenceService.of(BackendlessUser.ofClass())
        
        // now that we have dataStore we can do the query to get our users
        dataStore!.find(dataQuery, response: { (users) in
            print("PRINTING USERS - \(String(describing: users))")
            //self.users = users!.data as! [BackendlessUser]
            self.users = users! as! [BackendlessUser]
            self.tv.reloadData()
            
        }) { fault in
            
            ProgressHUD.showError("Couldn't load users: \(fault!.detail!)")
        }
    }
    
    
    // MARK: Search controller
    
    func filteredContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredUsers = users.filter { user in
            
            return user.name.lowercased.contains(searchText.lowercased()) // convert what user types to lower case and check if they match
        }
        
        tv.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    
    
    
    
    
    
    

}
