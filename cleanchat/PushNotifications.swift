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
    let newMembersArray = removeCurrrentUserFromMembersArray(members: members)
    
    // get backendless user based on their objectId
    getMembersToPush(members: newMembersArray) { (userArray) in
        
        for user in userArray
        // send push notif
        sendPushNotifcation(toUser: user, message: message)
        
    }
}


func sendPushNotifcation(toUser: BackendlessUser, message: String) {
    
    // message, badge count, sound
}

func numberOfUnreadMessagesOfUser(userID: String, result: @escaping (_ counter: Int) -> Void) {
    
    var counter = 0
    var resultCounter = 0 // used to see when we're done going thru all our recents
    
    ref.queryOrdered(byChild: kUSERID).queryEqual(toValue: userID).observe(.value) { (snap) in
        
        // checked all the recents that belong to current user
        
        if snap.exists() {
            
            let recents = (snap.value! as NSDictionary).allValues!
            
            for recent in recents {
                
                let currentRecent = recent as! NSDictionary
                let tempCount = (currentRecent[kCOUNTER] as? Int)!
                resultCounter += 1
                counter += tempCount
                
                if shouldSendPush {
                    // check we get as many results as we received from firebase
                    if resultCounter == recents.count {
                        result(counter)
                    }
                }
            }
        }
    }
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


func getMembersToPush(members: [String], result: @escaping (_ usersArray: [BackendlessUser]) -> Void) {
    
    var backendlessMembers: [BackendlessUser] = []
    
    var count = 0
    
    for memberID in members {
        
        // query b.e. user table
        let whereClause = "objectId = '\(memberID)'"
        let dq = DataQueryBuilder()
        dq?.setWhereClause(whereClause)
        
        let ds = backendless!.persistenceService.of(BackendlessUser.ofClass())
        ds!.find(dq, response: { (users) in
            // since we're searching for specific userID this means we'll only get one user back
            let user = users!.first as! BackendlessUser
            backendlessMembers.append(user)
            count += 1
            
            if members.count == count { // means we've received all the members from our members array that was passed into this func
                result(backendlessMembers)
            }
            
        }) { (fault) in
            print("COULDNT GET USERS TO PUSH: \(fault!.detail)")
            
        }
    }
}




