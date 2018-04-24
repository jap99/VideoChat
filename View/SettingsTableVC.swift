//
//  SettingsTableVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/24/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit
import MobileCoreServices // so we can use our user defaults

class SettingsTableVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

  
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // in section 1 we'll have our avatar cell, 2 will have our other cells, 3 will be logout - we're separating them
        
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 { return 1 }
        if section == 1 { return 4 }
        if section == 2 { return 1 }
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            // hence we're in section 1 row 1 = avatar cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarCell", for: indexPath) as! FriendCell
            
            cell.bindData(friend: backendless!.userService.currentUser!)
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            // second section, first row = privacy cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "privacyCell", for: indexPath)
            
            cell.textLabel?.text = "Privacy Policy"
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            // second section, second row = terms cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "termsCell", for: indexPath)
            
            cell.textLabel?.text = "Terms of Service"
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 2 {
            // second section, third row = bg cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "backgroundCell", for: indexPath)
            
            cell.textLabel?.text = "Backgrounds"
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            // second section, fourth row = show avatar cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "showAvatarCell", for: indexPath)
            
            return cell
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            // third section, first row = privacy cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
            
            return cell
        }
        
        return UITableViewCell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
