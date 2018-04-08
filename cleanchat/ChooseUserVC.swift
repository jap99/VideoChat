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

        
    }
 
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
