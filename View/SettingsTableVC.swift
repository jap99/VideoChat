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
            let cell = tableView.dequeueReusableCell(withIdentifier: "showAvatarCell", for: indexPath) as! ShowAvatarCell
            
            return cell
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            // third section, first row = privacy cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = tableView.backgroundColor // so our table view headers don't have different background colors
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            // only our avatar cell is here
            return 50
        } else {
            return 20
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            // in avatar section
            return 70
        } else {
            return 44 // standard table view cell height
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            // in avatar cell
            
            // show profile VC
            
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            // show privacy cell
            
            
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            // show terms of service cell
            
            
        }
        
        if indexPath.section == 1 && indexPath.row == 2 {
            // show bg cell
            
            
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            // show logout
            showLogoutView()
        }
    }
    
    func showLogoutView() {
        
        // warning before we logout
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logOut = UIAlertAction(title: "Log Out", style: .destructive) { (alert) in
            
            // log out user
            self.logOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in  })
        
        optionMenu.addAction(logOut)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func logOut() {
        backendless!.userService.logout()
        
        // logout from facebook
        
        // resign from push notifications
        
        // show loginVC
        let login = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeView")
        
        self.present(login, animated: true, completion: nil)
    }
    
    
    
    
    
}
