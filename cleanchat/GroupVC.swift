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

       
    }

    
    // MARK: Table View Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // get the group for the specific cell
        let group = groups[indexPath.row]
        
        cell.textLabel?.text = group[kNAME] as? String // group name
        
        return cell
    }
    
    
    // MARK: Table view delegate functions
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // because user can delete groups also
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // called when user clicks the delete button
    }
    
    
    
    // MARK: IBActions
    
    @IBAction func addBarButtonItemPressed(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "groupToAddGroup-Segue", sender: self)
        
    }
    
    
    

}
