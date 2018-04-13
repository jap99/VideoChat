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



