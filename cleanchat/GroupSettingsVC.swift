//
//  GroupSettingsVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/27/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

class GroupSettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tv: UITableView!
    var group: NSDictionary? = nil // value is set in our segue - accesses the group
    var users: [BackendlessUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUsersFromBackendless(userIds: (group![kMEMBERS] as? [String])!)
        
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
        
        if indexPath.row == 0 {
            
            // start group chat
            startGroupChat(group: self.group!)
            
            let chatVC = ChatVC()
            chatVC.chatRoomId = self.group![kGROUPID] as? String
            chatVC.members = (self.group![kMEMBERS] as? [String])!
            chatVC.titleName = (self.group![kNAME] as? String)!
            chatVC.isGroup = true
            
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func editBarButtonItemPressed(_ sender: AnyObject) {
        
        // options: rename group, add more members
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let renameAction = UIAlertAction(title: "Rename Group", style: .default) { (action) in
            
        }
        
        let addMembers = UIAlertAction(title: "Add Members", style: .default) { (action) in
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in  }
        
        optionMenu.addAction(renameAction)
        optionMenu.addAction(addMembers)
        optionMenu.addAction(cancelAction)
    }
    
    
    
    // Helper function
    
    func getUsersFromBackendless(userIds: [String]) {
        
        users.removeAll()
        
        for userId in userIds {
            
            // get user
            let whereClause = "objectId = '\(userId)'"
            
            let dataQuery = DataQueryBuilder()
            
            dataQuery?.setWhereClause(whereClause)
            
            let ds = backendless!.persistenceService.of(BackendlessUser.ofClass())
            ds!.find(dataQuery, response: { (users) in
                
                let user = users?.first as! BackendlessUser
                self.users.append(user)
                self.tv.reloadData()
                
            }, error: { (fault) in
                
                ProgressHUD.showError("Couldn't load members: \(fault!.detail)")
            })
        }
    }
    
   
    

}
