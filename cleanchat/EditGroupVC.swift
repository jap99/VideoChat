//
//  EditGroupVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/28/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

protocol EditGroupDelegate {
    
    func finishedEditingGroup(updatedGroup: NSDictionary)
}

class EditGroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tv: UITableView!
    
    var group: NSDictionary?
    var groupMembers: [String] = []
    var friends: [BackendlessUser] = []
    var delegate: EditGroupDelegate!
    
    let dataStore = backendless!.data.of(Friend.ofClass())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadFriend()
        groupMembers = (group![kMEMBERS] as? [String])!
    }
    
    
    // MARK:
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendCell
        
        let user = friends[indexPath.row]
        
        cell.accessoryType = .none
        
        cell.bindData(friend: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friends.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) { // checking if we have a cell
            
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }
        
        // get seleceted user
        let selectedUser = friends[indexPath.row]
        
        let selected = groupMembers.contains(selectedUser.objectId as String)
        
        if selected {
            
            let objectIndex = groupMembers.index(of: selectedUser.objectId as String)
            // remove seleceted user from group
            groupMembers.remove(at: objectIndex!)
        } else {
            groupMembers.append(selectedUser.objectId as String)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        
        let groupId = group![kGROUPID] as? String
        let values = [kMEMBERS: groupMembers]
        
        firebase.child(kGROUP).child(groupId!).updateChildValues(values)
        
        // update all recents that belong in current group
        updateMembersInRecent(members: groupMembers, group: group!)
        
        // tell delegate we've finished adding members/editing our group
        group!.setValue(groupMembers, forKey: kMEMBERS)
        delegate.finishedEditingGroup(updatedGroup: group!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: load friends
    
    func loadFriend() {
        
        cleanup()
        
        var friendIds = [String]()
        
        let whereClause = "userOneId = '\(backendless!.userService.currentUser.objectId!)'"
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(whereClause)
        
        dataStore?.find(queryBuilder, response: {
            (friendsFromBackendless) -> () in
            
            
            if friendsFromBackendless != nil {
                
                let localFriends = friendsFromBackendless! as! [Friend]
                
                
                for friend in localFriends {
                    
                    if !(self.group![kMEMBERS] as? [String])!.contains((friend.userTwo)! as String) {
                        
                        friendIds.append(friend.userTwo!)
                    }
                    
                }
                
                //get friends from thier Ids
                self.fetchFriends(withIds: friendIds)
                self.tv.reloadData()
            }
            
        }, error: {
            (fault : Fault?) -> () in
            ProgressHUD.showError("Couldnt load friends: \(fault!.detail!)")
        })
        
        
    }
    
    //new function
    func fetchFriends(withIds: [String]) {
        
        let string = "'" + withIds.joined(separator: "', '") + "'"
        let whereClause = "objectId IN (\(string))"
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(whereClause)
        
        let dataStore = backendless!.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore?.find(queryBuilder, response: {
            (allUsers) -> () in
            
            if allUsers != nil {
                
                for friendUser in allUsers as! [BackendlessUser] {
                    self.friends.append(friendUser)
                }
                self.tv.reloadData()
            }
            
        }, error: {
            (fault : Fault?) -> () in
            print("Couldnt load all friends: \(fault!.detail)")
        })
        
        
    }

    
    
    func cleanup() {
        friends.removeAll()
        tv.reloadData()
    }
    
    
    
    
    
    
    
}
















