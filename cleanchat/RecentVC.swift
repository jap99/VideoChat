//
//  RecentVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/22/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import UIKit

class RecentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tv: UITableView!
    
    var recents: [NSDictionary] = []
    var firstLoad: Bool? // checks if it's user's first time loading the app and if we need to do setup
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = lead
        
        loadRecents()
        tv.delegate = self; tv.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
    }

    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return recents.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell") as! RecentCell
        let recent = recents[indexPath.section]
        
        cell.bindData(recent: recent)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .black
        return headerView
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let recent = recents[indexPath.section]
        
        if (recent[kTYPE] as? String)! == kGROUP {
            
            recentDeleteWarning(indexPath: indexPath)
            
        } else {
            
            recents.remove(at: indexPath.section)
            deleteRecentItem(recentID: (recent[kRECENTID] as? String)!)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // present chatVC
        let recent = recents[indexPath.section]
        
        // restart recents
        restartRecentChat(recent: recent)
        
        let chatVC = ChatVC()
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.titleName = (recent[kWITHUSERUSERNAME] as? String)!
        chatVC.members = (recent[kMEMBERS] as? [String])!
        chatVC.chatRoomId = (recent[kCHATROOMID] as? String)!
        if (recent[kTYPE] as? String)! == kGROUP {
            chatVC.isGroup = true 
        }
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func addRecentBarButtonPressed(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let friendList = UIAlertAction(title: "Message A Friend", style: .default) { (alert) in
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC-ID") as! UITabBarController
            vc.selectedIndex = 2
            self.present(vc, animated: true, completion: nil)
        }
        let allUsers = UIAlertAction(title: "Message Another User", style: .default) { (alert) in
            self.performSegue(withIdentifier: "recentToChooseUserSeg", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in }
        optionMenu.addAction(friendList)
        optionMenu.addAction(allUsers)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK: - Load Recents
    
    func loadRecents() {
        
        firebase.child(kRECENT).queryOrdered(byChild: kUSERID).queryEqual(toValue: backendless!.userService.currentUser.objectId).observe(.value) { (snapshot) in
            
            self.recents.removeAll() // in case we have anything in our array already
            
            if snapshot.exists() { // if we have a value in snapshot
                
                // sort by date - most recent value on top
                let sorted = ((snapshot.value as! NSDictionary).allValues as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) // sorted is an array of dictionaries
                
                for recent in sorted {
                    let currentRecent = recent as! NSDictionary
                    
                    self.recents.append(currentRecent)
                    
                    // another query to have all the users for the chatroom ID but make sure we don't query recents that don't belong to our user by referring to currentRecent[kCHATROOMID].observe...
                    //this query below prevents additional recents from being created in firebase when a user is selected and our online and offline databases are in sync
                    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: currentRecent[kCHATROOMID]).observe(.value, with: { (snapshot) in
                        
                    })
                    
                }
            }
            
            self.tv.reloadData()
        }
    }
    
    func restartRecentChat(recent: NSDictionary) {
        
        // one reason we'll need to call this is if a user has deleted his recent then we'll need to create a new one and update it for both users
        
        // private chat vs. group chat
        if recent[kTYPE] as! String == kPRIVATE {
            
            for userId in recent[kMEMBERS] as! [String] {
                
                if userId != backendless!.userService.currentUser.objectId! as String {
                    
                    createRecent(userId: userId, chatRoomId: (recent[kCHATROOMID] as? String)!, members: recent[kMEMBERS] as! [String], withUserUserId: backendless!.userService.currentUser.objectId! as String, withUserUsername: backendless!.userService.currentUser.name! as String, type: kPRIVATE)
                }
            }
        }
        
        if recent[kTYPE] as! String == kGROUP {
            
            // create group recent here
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String) {
        
        // update recents with our new message everytime we send a new message
        
        // accessing all the recents that have the same chatroomId
        firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomId).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                
                for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                    
                    // update recent item
                    self.updateRecentItem(recent: recent as! NSDictionary, lastMessage: lastMessage)
                }
            }
        }
    }
    
    func updateRecentItem(recent: NSDictionary, lastMessage: String) {
        
        // update the date
        let date = dateFormatter().string(from: Date())
        
        // increment counter since we just sent a message
        var counter = recent[kCOUNTER] as! Int
        
        if (recent[kUSERID] as! String) != backendless!.userService.currentUser.objectId as String? {
            counter += 1
        }
        
        let values = [kLASTMESSAGE: lastMessage,
                      kCOUNTER: counter,
                      kDATE: date
            ] as [String: AnyObject]
        
        firebase.child(kRECENT).child((recent[kRECENTID] as? String)!).updateChildValues(values as [NSObject: AnyObject]) { (error, ref) -> Void in
            
            if error != nil {
                ProgressHUD.showError("Couldn't update recent: \(String(describing: error!.localizedDescription))")
            }
            
        }
    }
    
    
    
    // MARK: Helper functions
    
    func recentDeleteWarning(indexPath: IndexPath) {
        
        let ac = UIAlertController(title: "Attention", message: "Would you like to receive notifications from this group?", preferredStyle: .alert)
        
        // get our recent
        let recent = recents[indexPath.row]
        
        // remove recent from recents array
        recents.remove(at: indexPath.row)
        
        let yesAction = UIAlertAction(title: "Yes?", style: .default) { (action) in
            
            deleteRecentItem(recentID: (recent[kRECENTID] as? String)!)
            self.tv.reloadData()
        }
        
        let noAction = UIAlertAction(title: "No", style: .destructive) { (action) in
            
            // delete recent with notification
            deleteRecentWithNotification(recent: recent)
            
            self.tv.reloadData()
        }
        
        ac.addAction(yesAction);    ac.addAction(noAction)
        self.present(ac, animated: true, completion: nil)
    }
    
    
    
}
