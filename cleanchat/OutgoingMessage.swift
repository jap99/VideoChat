//
//  OutgoingMessage.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/13/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

class OutgoingMessage {
    
    let ref = firebase.child(kMESSAGE)
    
    // generate our message
    let messageDictionary: NSMutableDictionary
    
    // text
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    // location
    init(message: String, latitude: NSNumber, longitude: NSNumber, senderId: String, senderName: String, date: Date, status: String, type: String) {
         messageDictionary = NSMutableDictionary(objects: [message, latitude, longitude, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kLATITUDE as NSCopying, kLONGITUDE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    // picture
    init(message: String, pictureData: NSData, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        // convert NSData to a string we can save to firebase
        let pic = pictureData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        messageDictionary = NSMutableDictionary(objects: [message, pic, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
        
    }
    
    // video
    init(message: String, video: String, thumbnail: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
         messageDictionary = NSMutableDictionary(objects: [message, video, thumbnail, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kVIDEO as NSCopying, kTHUMBNAIL as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    // audio
    init(message: String, audio: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
         messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kAUDIO as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    func sendMessage(chatRoomID: String, item: NSMutableDictionary) {
        
        let reference = ref.child(chatRoomID).childByAutoId()
        
        // set id
        item[kMESSAGEID] = reference.key
        
        // save it
        reference.setValue(item) { (error, ref) in
            
            if error != nil {
                
                ProgressHUD.showError("Outgoing message error \(String(describing: error!.localizedDescription))")
            }
        }
        
        // update recent so it shows correct message info
        updateRecents(chatRoomId: chatRoomID, lastMessage: (item[kMESSAGE] as? String)!)
        
        // send push notification
        sendPushNotification1(chatRoomID: chatRoomID, message: (item[kMESSAGE] as? String)!)
    }
    
    
    
    
    
    
    
    
    
    
    
}
