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
    let currentUser = backendless!.userService.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
 
    // MARK: IBActions
    
    @IBAction func addFriendsBarButton_Pressed (_ sender: AnyObject) {
        
    }

    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredFriends.count // because while user's searching we're putting all the results in filteredFriends
        }
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell") as! FriendCell
        
        // access b.e. user & set it depending on it we're searching or not searching at the moment
        var friend: BackendlessUser
        
        // check if search controller's active or not first
        if searchController.isActive && searchController.searchBar.text != "" {
            
            friend = filteredFriends[indexPath.row]
        } else {
            
            friend = friends[indexPath.row]
        }
        
        cell.bindData(friend: friend)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true // so we can delete our friends
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // delete friend
        
    }
    
    
    // MARK: Table view delegate functions
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // when user selects friend then chat with them
        
        tv.deselectRow(at: indexPath, animated: true)
        
        // then get our friend
        var friend: BackendlessUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            friend = filteredFriends[indexPath.row]
            
        } else {
            
            friend = friends[indexPath.row]
        }
        
        // create a chat: when we get access to our friend we'll create a chat with him
    }
    
    func loadFriends() {
        
        // make sure old info is removed from array
        cleanup()
        
        // when we access our friends we'll select all of them from b.e.
        
        // load all the friends that belong to our current user
        let whereClause = "userOneId = '\(currentUser?.objectId!)'"
        let dataQuery = DataQueryBuilder()
        dataQuery?.setWhereClause(whereClause)
        
        dataStore!.find(dataQuery, response: { (friends_) in
            
            if friends_ != nil {
                
                let friends = friends_?.data as! [Friend]
                
                for friend in friends {
                    
                    self.friends.append(friend.userTwo!)
                    
                }
                self.tv.reloadData() // to display the friends we've added to our array
                
                if self.friends.count == 0 {
                    
                    ProgressHUD.show("Currently there are no added friends", interaction: false)
                }
            }
            
        }) { (fault) in
            
            ProgressHUD.showError("Couldn't load friends. Error: \(fault!.detail)")
        }
    }
    
    
    // MARK: Helper functions
    
    func cleanup() {
        
        friendObjects.removeAll()
        friends.removeAll()
        tv.reloadData()
    }
    
    // MARK: Search controller
    
    func filteredContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredFriends = friends.filter { friend in
            
            return friend.name.lowercased.contains(searchText.lowercased()) // convert what user types to lower case and check if they match
        }
        
        tv.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    
    
}
