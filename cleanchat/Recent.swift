//
//  Recent.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/9/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

func startChat(user1: BackendlessUser, user2: BackendlessUser) -> String {
    
    // get the users' Id
    let userId1 = user1.objectId as String
    let userId2 = user2.objectId as String
    
    // create a chat room id from those two Id's
    var chatRoomId: String = ""
    
    // compare the two user's Id and make sure we use the same chat room if chat was previously started
    let value = userId1.compare(userId2).rawValue
    
    if value < 0 {
        chatRoomId = userId1 + userId2
    } else {
        chatRoomId = userId2 + userId1
    }
    
    let members = [userId1, userId2]
    
    // create a recent for each user
    createRecent(userId: userId1, chatRoomId: chatRoomId, members: members, withUserUserId: userId2, withUserUsername: user2.name! as String, type: kPRIVATE)
    createRecent(userId: userId2, chatRoomId: chatRoomId, members: members, withUserUserId: userId1, withUserUsername: user1.name! as String, type: kPRIVATE)
    
    return chatRoomId
}

func createRecent(userId: String, chatRoomId: String, members: [String], withUserUserId: String, withUserUsername: String, type: String) {
    
    // query all the recents where the chatroomId is equal to the chatroomId being passed into this func
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomId).observeSingleEvent(of: .value, with: { snapshot in
        
        var create = true
        
        if snapshot.exists() {
            
            for recent in (snapshot.value as! NSDictionary).allValues as Array {
                
                let currentRecent = recent as! NSDictionary
                
                // if a recent already exists then no need to create a new one
                if currentRecent[kUSERID] as! String == userId {
                    
                    create = false // no need to create one
                }
            }
        }
        
        if create {
            
            // create recent item
            createRecentItem(userId: userId, chatRoomId: chatRoomId, members: members, withUserUserId: withUserUserId, withUserUsername: withUserUsername, type: type)
        }
    })
}

func createRecentItem(userId: String, chatRoomId: String, members: [String], withUserUserId: String, withUserUsername: String, type: String) {
    
    let reference = firebase.child(kRECENT).childByAutoId()
    let recentId = reference.key
    let date = dateFormatter().string(from: Date())
    
    // the object we'll save in firebase is a dictionary so we'll create one
    let recent = [kRECENTID: recentId,
                  kUSERID: userId,
                  kCHATROOMID: chatRoomId,
                  kMEMBERS: members,
                  kWITHUSERUSERNAME: withUserUsername,
                  kWITHUSERUSERID: withUserUserId,
                  kLASTMESSAGE: "",
                  kCOUNTER: 0,
                  kDATE: date,
                  kTYPE: type
    ] as [String: Any]
    
    reference.setValue(recent) { (error, ref) in
        
        if error != nil {
            
            ProgressHUD.showError("Couldn't create recent: \(error!.localizedDescription)")
        }
    }
}

func updateChatStatus(chat: NSDictionary, chatRoomId: String) {
    
    let values = [kSTATUS: kREAD]
    
    firebase.child(kMESSAGE).child(chatRoomId).child((chat[kMESSAGEID] as? String)!).updateChildValues(values)
}


// group chats

func startGroupChat(group: NSDictionary) {
    
    // create a recent item for our group
    createGroupRecent(chatRoomId: (group[kGROUPID] as? String)!, members: (group[kMEMBERS] as? [String])!, groupName: (group[kNAME] as? String)!, ownerID: backendless!.userService.currentUser.objectId as String, type: kGROUP)
}

func createGroupRecent(chatRoomId: String, members: [String], groupName: String, ownerID: String, type: String) {
    
    // query recents that belong to our chatroomId
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomId).observeSingleEvent(of: .value) { (snapshot) in
        
        var memberIDs = members
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                let currentRecent = recent as! NSDictionary
                
                // check if we already have a recent for this member; if the member does already have a recent then go into condition
                
                if members.contains((currentRecent[kUSERID] as? String)!) {
                    
                    // get index of current item in order to delete it
                    let index = memberIDs.index(of: (currentRecent[kUSERID] as? String)!)
                    
                    memberIDs.remove(at: index!)
                }
            }
        }
        
        for userID in memberIDs {
            
            // check who doesn't have a recent and create a recent for them
            createRecentItem(userId: userID, chatRoomId: chatRoomId, members: members, withUserUserId: "", withUserUsername: groupName, type: type)
        }
        
    }
}


func restartRecentChat(recent: NSDictionary) {
    
    if (recent[kTYPE] as? String)! == kPRIVATE {
        
        for userId in recent[kMEMBERS] as! [String] {
            
            if userId != backendless!.userService.currentUser.objectId as! String {
                
                createRecent(userId: userId,
                             chatRoomId: (recent[kCHATROOMID] as? String)!,
                             members: recent[kMEMBERS] as! [String],
                             withUserUserId: backendless!.userService.currentUser.objectId! as String,
                             withUserUsername: backendless!.userService.currentUser.name! as String,
                             type: kPRIVATE)
            }
        }
    }
    
    if (recent[kTYPE] as? String)! == kGROUP {
        
        // create group recent here
        
        // in case a user has delete his recent we'll create another one
        
        createGroupRecent(chatRoomId: (recent[kCHATROOMID] as? String)!,
                          members: (recent[kMEMBERS] as? [String])!,
                          groupName: (recent[kWITHUSERUSERNAME] as? String)!,
                          ownerID: (recent[kUSERID] as? String)!,
                          type: kGROUP)
    }
}

func clearRecentCounter(chatRoomID: String) {
    
    // get all recents belonging to current chatroom
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value) { (snapshot) in
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                let currentRecent = recent as! NSDictionary
                
                // get the one that belongs to current user
                if currentRecent[kUSERID] as? String == backendless!.userService.currentUser.objectId as String {
                    
                    // clear counter
                    clearRecentCounterItem(recent: currentRecent)
                }
            }
        }
    }
}

func clearRecentCounterItem(recent: NSDictionary) {
    
    firebase.child(kRECENT).child((recent[kRECENTID] as? String)!).updateChildValues([kCOUNTER: 0]) { (error, ref) -> Void in
        
        if error != nil {
            ProgressHUD.showError("Couldn't clear recent counter: \(error!.localizedDescription)")
        }
    }
}

func updateRecentItem(recent: NSDictionary, lastMessage: String) {
    
    let date = dateFormatter().string(from: Date())
    
    var counter = recent[kCOUNTER] as! Int
    
    if recent[kUSERID] as? String != backendless!.userService.currentUser.objectId as? String {
        
        counter = counter + 1
    }
    
    let values = [kLASTMESSAGE: lastMessage,
                  kCOUNTER: counter,
                  kDATE: date] as [String: Any]
    
    firebase.child(kRECENT).child((recent[kRECENTID] as? String)!).updateChildValues(values as [NSObject: AnyObject]) {
        (error, ref) -> Void in
        
        if error != nil {
            
            ProgressHUD.showError("Couldn't update recent: \(error!.localizedDescription)")
        }
    }
}


func updateRecents(chatRoomId: String, lastMessage: String) {
    
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomId).observeSingleEvent(of: .value) { (snapshot) in
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                updateRecentItem(recent: recent as! NSDictionary, lastMessage: lastMessage)
            }
        }
    }
}


func deleteRecentItem(recentID: String) {
    
    firebase.child(kRECENT).child(recentID).removeValue { (error, ref) in
        
        if error != nil {
            
            ProgressHUD.showError("Couldn't delete recent item: \(error!.localizedDescription)")
        }
    }
}


func deleteMultipleRecentItems(chatRoomID: String) { // will be called in our group
    
    // get all the recents that belong to our chatRoomId
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value) { (snapshot) in
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                let currentRecent = recent as! NSDictionary
                
                deleteRecentItem(recentID: (currentRecent[kRECENTID] as? String)!)
            }
        }
    }
}


func deleteRecentWithNotification(recent: NSDictionary) {
    
    // get members from recent and update them
    
    // find out which index has our current user
    let index = (recent[kMEMBERS] as? [String])!.index(of: backendless!.userService.currentUser.objectId as! String)
    
    var newMembers = (recent[kMEMBERS] as? [String])!
    newMembers.remove(at: index!)
    
    // check how many people are in the group; no point in having a one member group so will delete it
    if (recent[kMEMBERS] as? [String])!.count > 2 {
        
        firebase.child(kGROUP).queryOrdered(byChild: kGROUPID).queryEqual(toValue: recent[kCHATROOMID] as? String).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                
                for group in ((snapshot.value as! NSDictionary).allValues as Array) {
                    
                    // 1. delete recent
                    deleteRecentItem(recentID: (recent[kRECENTID] as? String)!)
                    
                    // 2. remove current user from group members
                    
                    // 3. Remove current user from recents
                }
            }
        }
    } else {
        
        // delete the group
        Group.deleteGroup(groupId: (recent[kCHATROOMID] as? String)!)
    }
}





