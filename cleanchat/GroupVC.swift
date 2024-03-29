//
//  GroupVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/27/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

class GroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var groups: [NSDictionary] = []
    
    @IBOutlet weak var tv: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = ""
        
        loadGroups()
       
    }

    
    // MARK: Table View Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // get the group for the specific cell
        let group = groups[indexPath.row]
        let membersCount = (group[kMEMBERS] as? [String])!.count
        cell.textLabel?.text = group[kNAME] as? String // group name
        cell.detailTextLabel?.text = "\(membersCount) members"
        
        return cell
    }
    
    
    // MARK: Table view delegate functions
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tv.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "groupToGroupSettings-Segue", sender: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // because user can delete groups also
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // called when user clicks the delete button
        
        // check they didn't click by mistake
        groupDeleteWarning(indexPath: indexPath)
    }
    
    
    // MARK: Load groups
    
    func loadGroups() {
        
        // get all groups from firebase
        // query all groups that belong to current user
        firebase.child(kGROUP).queryOrdered(byChild: kOWNERID).queryEqual(toValue: backendless!.userService.currentUser.objectId!).observe(.value) { (snapshot) in
            
            self.groups.removeAll()
            
            if snapshot.exists() {
                
                // create an array and sort by the date they were created
                let sorted = ((snapshot.value! as! NSDictionary).allValues as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)])
                
                // go through groups
                for group in sorted {
                    
                    self.groups.append(group as! NSDictionary)
                    
                }
            }
            
            self.tv.reloadData() // reloaded when add a new group to our array
        }
    }
    
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "groupToAddGroup-Segue" {
            
            let vc = segue.destination as! AddGroupVC
            vc.hidesBottomBarWhenPushed = true
        
        } else if segue.identifier == "groupToGroupSettings-Segue" {
            
            let indexPath = sender as! NSIndexPath
            
            let vc = segue.destination as! GroupSettingsVC
            
            // give settings vc the group that user selected so it can display this group
            vc.group = self.groups[indexPath.row]
        }
    }
    
    
    
    // MARK: IBActions
    
    @IBAction func addBarButtonItemPressed(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "groupToAddGroup-Segue", sender: self)
        
    }
    
    
    // MARK: Helper functions
    
    func groupDeleteWarning(indexPath: IndexPath) {
        
        let ac = UIAlertController(title: "Warning!", message: "This will delete all group messages.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in   }
        
        let deleteAction = UIAlertAction(title: "Delete?", style: .destructive) { (action) in
            // get the group we want to delete
            let group = self.groups[indexPath.row]
            // remove current group from array
            self.groups.remove(at: indexPath.row)
            
            Group.deleteGroup(groupId: (group[kGROUPID] as? String)!)
            
            self.tv.reloadData()
        }
        
        ac.addAction(cancelAction); ac.addAction(deleteAction)
        self.present(ac, animated: true, completion: nil)
        
    }
    
    

}
