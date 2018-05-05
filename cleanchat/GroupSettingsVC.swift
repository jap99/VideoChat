//
//  GroupSettingsVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/27/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

class GroupSettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, EditGroupDelegate {

    @IBOutlet weak var tv: UITableView!
    var groupNameTextField: UITextField!
    
    var group: NSDictionary? = nil // value is set in our segue - accesses the group
    var users: [BackendlessUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUsersFromBackendless(userIds: (group![kMEMBERS] as? [String])!)
        self.navigationItem.rightBarButtonItem?.tintColor = darkBlue
        
    }

    
    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1 // group's name
       
        } else {
            
            return users.count // member's name - count how many users we have in our group
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         if indexPath.section == 0 {
            
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = group![kNAME] as? String // setting the group name
            
            return cell
            
         } else {
            
            // members section
            let cell = tv.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
            
            // puts users in table view cell
            cell.bindData(friend: users[indexPath.row])
            
            return cell 
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section != 0 {
            // not our first section
            return "Members"
            } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 20.0
        } else {
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // take user to chat with the group
        
        tv.deselectRow(at: indexPath, animated: true)
        
        // check which row we're selecting to see which user to chat with
        
        if indexPath.section == 0 { // SECTION 0 is our GROUP; SECTION 1 is our USER
            
            // start group chat
            startGroupChat(group: self.group!)
            
            let chatVC = ChatVC()
            chatVC.chatRoomId = self.group![kGROUPID] as? String
            chatVC.members = (self.group![kMEMBERS] as? [String])!
            chatVC.titleName = (self.group![kNAME] as? String)!
            chatVC.isGroup = true
            
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
       
        } else { // if user taps on a user then we'll show them that user's profile
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC-ID") as! ProfileVC
            
            vc.user = users[indexPath.row]
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func editBarButtonItemPressed(_ sender: AnyObject) {
        
        // options: rename group, add more members
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let renameAction = UIAlertAction(title: "Rename Group", style: .default) { (action) in
            self.renameGroup()
        }
        
        let addMembers = UIAlertAction(title: "Add Members", style: .default) { (action) in
            
            self.performSegue(withIdentifier: "groupSettingsToAddMember-Segue", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in  }
        
        optionMenu.addAction(renameAction)
        optionMenu.addAction(addMembers)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    func renameGroup() {
        
        let ac = UIAlertController(title: "Rename Group", message: "Enter a new name for this group", preferredStyle: .alert)
        
        // add text field to alert
        ac.addTextField { (nameTextField) in
            
            nameTextField.placeholder = "Name"
            self.groupNameTextField = nameTextField
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in }
        
        let save = UIAlertAction(title: "Save", style: .default) { (action) in
            
            if self.groupNameTextField.text != "" {
                
                // update firebase group name
                self.updateFirebaseGroupName(newName: self.groupNameTextField.text!)
            }
        }
        
        ac.addAction(save); ac.addAction(cancel); self.present(ac, animated: true, completion: nil)
    }
    
    
    func updateFirebaseGroupName(newName: String) {
        
        // update local new first so it's automatically updated
        let newGroup = group!.mutableCopy() as! NSMutableDictionary
        newGroup.setValue(newName, forKey: kNAME)
        group = newGroup
        
        tv.reloadData()
        
        // update group in firebase
        let groupId = group![kGROUPID] as? String
        let values = [kNAME: newName]
        
        firebase.child(kGROUP).child(groupId!).updateChildValues(values)
        
        // update name in all the recents also now
        firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: groupId!).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                
                for recent in (snapshot.value! as! NSDictionary).allValues {
                    
                    // update group name in recents
                    self.updateRecentGroupName(newName: newName, recent: recent as! NSDictionary)
                }
            }
        }
    }
    
    
    func updateRecentGroupName(newName: String, recent: NSDictionary) {
        
        let values = [kWITHUSERUSERNAME: newName]
        
        firebase.child(kRECENT).child((recent[kRECENTID] as? String)!).updateChildValues(values) { (error, ref) in
            
            if error != nil {
                
                ProgressHUD.showError("Couldn't update group name: \(error!.localizedDescription)")
            }
        }
    }
    
    
    // Helper function
    
    func getUsersFromBackendless(userIds: [String]) {
        
        users.removeAll()
        
        for userId in userIds {
            
            // get user
            let whereClause = "objectId = '\(userId)'"
            
            let dataQuery = DataQueryBuilder()
            
            dataQuery!.setWhereClause(whereClause)
            
            let ds = backendless!.persistenceService.of(BackendlessUser.ofClass())
            ds!.find(dataQuery, response: { (users) in
                
                let user = users?.first as! BackendlessUser
                self.users.append(user)
                self.tv.reloadData()
                
            }, error: { (fault) in
                
                ProgressHUD.showError("Couldn't load members: \(fault!.detail!)")
            })
        }
    }
    
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "groupSettingsToAddMember-Segue" {
            
            let vc = segue.destination as! EditGroupVC
            vc.group = self.group
            vc.delegate = self
        }
    }
    
    // MARK: Edit group delegate
    
    func finishedEditingGroup(updatedGroup: NSDictionary) {
        
        self.group = updatedGroup
        getUsersFromBackendless(userIds: (group![kMEMBERS] as? [String])!)
    }
   
    

}
