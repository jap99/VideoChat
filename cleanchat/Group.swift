//
//  Group.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/27/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

class Group {
    
    // saving group to firebase
    
    let groupDictionary: NSMutableDictionary
    
    init(name: String, ownerId: String, members: [String]) {
        
        groupDictionary = NSMutableDictionary(objects: [name, ownerId, members], forKeys: [kNAME as NSCopying, kOWNERID as NSCopying, kMEMBERS as NSCopying])
    }
    
    // can be called without instantiating a group
    
    class func saveGroup(group: NSMutableDictionary) {
        
        let reference = firebase.child(kGROUP).childByAutoId()
        let date = dateFormatter().string(from: Date())
        
        group[kGROUPID] = reference.key
        group[kDATE] = date
        
        reference.setValue(group) { (error, ref) in
            
            if error != nil {
                ProgressHUD.showError("ERROR SAVING GROUP: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    class func deleteGroup(groupId: String) {
        
        firebase.child(kGROUP).child(groupId).removeValue { (error, ref) in
            if error != nil {
                ProgressHUD.showError("COULDN'T DELETE GROUP: \(error!.localizedDescription)")
            } else {
                // delete recents
                deleteMultipleRecentItems(chatRoomID: groupId)
               
                // delete all messages
            }
        }
    }
    
    
}
