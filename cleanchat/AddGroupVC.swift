//
//  AddGroupVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/27/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

class AddGroupVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    
    var friends: [BackendlessUser] = []
    var groupMembers: [String] = [] // for userIds of each member
    
    let dataStore = backendless!.data.of(Friend.ofClass())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // put header view on top of tv
        self.tv.tableHeaderView = headerView
        
        loadFriends()
    }

    
    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // return a friend cell
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendCell
        
        cell.accessoryType = .none
        
        // get the specific friend for each cell
        let user = friends[indexPath.row]
        
        cell.bindData(friend: user)
        return cell
    }
    
    
    // MARK: table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // change our checkmark
        
        // check if we have a cell first and if it's checked or not
        if let cell = tv.cellForRow(at: indexPath) {
            
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
                // when we add the checkmark we add the member to our groupMembers array
            }
        }
        
        // get selected user and add to our selected user's array if not there yet
        
        let selectedUser = friends[indexPath.row]
        
        // check if user's Id was already in our array
        let selected = groupMembers.contains(selectedUser.objectId as String)
        
        if selected {
            // get index of our selected user in order to remove it from our array
            let objectIndex = groupMembers.index(of: selectedUser.objectId as String)
            groupMembers.remove(at: objectIndex!)
        } else {
            // add selected member to group
            groupMembers.append(selectedUser.objectId as String)
        }
    }
    
    
    func cleanup() { // called before we load our friends in case we already have users in our array
        groupMembers.removeAll(); friends.removeAll(); tv.reloadData()
    }
    
    // MARK: Load Users
    
    func loadFriends() {
        
        cleanup()
        
        var friendIds = [String]()
        
        // check all the friends that belong to our current user
        let whereClause = "userOneId = '\(backendless!.userService.currentUser.objectId!)'"
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(whereClause)
        
        dataStore?.find(queryBuilder, response: {
            (allFriends) -> () in
            
            if allFriends != nil {
                let friends = allFriends! as! [Friend]
                
                for friend in friends {
                    friendIds.append(friend.userTwo!)
                }
                
            }
            //get friends from thier Ids
            self.fetchFriends(withIds: friendIds)
            
            self.tv.reloadData()
            
        }, error: {
            (fault : Fault?) -> () in
            ProgressHUD.showError("Couldnt load friends \(fault!.detail)")
        })
        
    }
    
    //new function
    func fetchFriends(withIds: [String]) {
        
        let string = "'" + withIds.joined(separator: "', '") + "'"
        let whereClause = "objectId IN (\(string))"
        
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(whereClause)
        
        let ds = backendless!.persistenceService.of(BackendlessUser.ofClass())
        
        ds?.find(queryBuilder, response: {
            (allUsers) -> () in
            
            if allUsers != nil {
                let friends = allUsers as! [BackendlessUser]
                
                for friendUser in friends {
                    self.friends.append(friendUser)
                }
                
                self.tv.reloadData()
                
                if self.friends.count == 0 {
                    ProgressHUD.showError("Currently you have no friends, please add some")
                }
            }
            
        }, error: {
            (fault : Fault?) -> () in
            print("Couldnt load all friends: \(fault!.detail)")
        })
        
        
    }
    
    // MARK: IBActions
    
    @IBAction func doneBarButtonItemPressed(_ sender: AnyObject) {
        
        // check if we have a group name
        if groupNameTextField.text == "" {
            
            ProgressHUD.showError("Group name must be set!")
            return
        }
        
        if groupMembers.count == 0 {
            // checking if any members have been added to group yet
            ProgressHUD.showError("Please select some users")
            return
        }
        
        // create a group if it has members; add current user to it
        groupMembers.append(backendless!.userService.currentUser.objectId as String)
        let name = groupNameTextField.text!
        
        // each group has an owener
        let ownerId = backendless!.userService.currentUser.objectId as String
        
        // create group 
        
    }
    
    
    
  
}
