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
    
    // MARK: IBActions
    
    @IBAction func editBarButtonItemPressed(_ sender: AnyObject) {
        
    }
    
    
    
    
    
   
    

}
