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
    
    var emptyLabel = UILabel()
    var doneButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        doneButton = self.navigationItem.rightBarButtonItem!
        // put header view on top of tv
        self.tv.tableHeaderView = headerView
        doneButton.tintColor = darkBlue
        //self.navigationItem.rightBarButtonItem?.tintColor = darkBlue
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
            ProgressHUD.showError("There was an issue loading your friend's list. Here's the error we got: \(fault!.detail!)")
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
                self.doneButton.isEnabled = true
                self.groupNameTextField.isHidden = false 
                for friendUser in friends {
                    self.friends.append(friendUser)
                }
                
                self.tv.reloadData()
                setupLabelForEmptyView(label: self.emptyLabel, message: nil, vc: nil, hide: true)
                
                if self.friends.count == 0 {
                    self.doneButton.isEnabled = false
                    self.groupNameTextField.isHidden = true
                    setupLabelForEmptyView(label: self.emptyLabel, message: "You must add friends to your account before creating a group.", vc: self, hide: false)
                }
            }
            
        }, error: {
            (fault : Fault?) -> () in
            print("We had a difficult time loading your friend's list. Here's the error we got: \(fault!.detail!)")
        })
        
        
    }
    
    // MARK: IBActions
    
    @IBAction func doneBarButtonItemPressed(_ sender: AnyObject) {
        
        // check if we have a group name
        if groupNameTextField.text == "" {
            
            ProgressHUD.showError("Give your group a name. Then add at least one friend and click Done!")
            return
        }
        
        if groupMembers.count == 0 {
            // checking if any members have been added to group yet
            ProgressHUD.showError("A group needs to have at least one additional member in order to be considered a group")
            return
        }
        
        // create a group if it has members; add current user to it
        groupMembers.append(backendless!.userService.currentUser.objectId as String)
        let name = groupNameTextField.text!
        
        // each group has an owener
        let ownerId = backendless!.userService.currentUser.objectId as String
        
        // create group
         let group = Group(name: name, ownerId: ownerId, members: groupMembers)
        
        // access our function to save it
        Group.saveGroup(group: group.groupDictionary)
        
        // get back to all our groups
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
  
}
