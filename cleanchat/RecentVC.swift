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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRecents()
        tv.delegate = self; tv.dataSource = self
    }
 
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell") as! RecentCell
        let recent = recents[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - IBActions
    
    @IBAction func addRecentBarButtonPressed(_ sender: Any) {
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
                    // right now we're accessing the recents of only our current user; to work offline though we need to access all recents
                    
                    
                }
            }
        }
    }
    

}
