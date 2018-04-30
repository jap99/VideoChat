//
//  PushNotifications.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/30/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

// each recent has an array of users so we'll need the recent to know who to send the push notifications to
let ref = firebase.child(kRECENT)
var shouldSendPush = false

func sendPushNotification1(chatRoomID: String, message: String) {
    
    // get all the recents that belong to the current chat room
    ref.queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value) { (snap) in
        
        if snap.exists() {
            
            let recents = (snap.value as! NSDictionary).allValues
            
            if let recent = recents.first as? NSDictionary {
                
                // call 2nd push notif
                sendPushNotification2(members: (recent[kMEMBERS] as? [String])!, message: message)
            }
        }
    }
}


func sendPushNotification2(members: [String], message: String) {
    
    // members has the data of all the users in a chat room, including current user so we want to remove current user to avoid sending him a push notification
    
}


func removeCurrrentUserFromMembersArray(members: [String]) -> [String] {
    
    var updatedMembersArray = [String]()
    
    for member in members {
        if member != backendless!.userService.currentUser.objectId as String {
            updatedMembersArray.append(member)
        }
    }
    return updatedMembersArray
}







