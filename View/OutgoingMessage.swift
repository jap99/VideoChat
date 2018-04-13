//
//  OutgoingMessage.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/13/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

class OutgoingMessages {
    
    let ref = firebase.child(kMESSAGE)
    
    // generate our message
    let messageDictionary: NSMutableDictionary
    
    // text
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
    }
    
    // location
    init(message: String, latitude: NSNumber, longitude: NSNumber, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
    }
    
    // picture
    init(message: String, pictureData: NSData, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
    }
    
    // video
    init(message: String, video: String, thumbnail: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
    }
    
    // audio
    init(message: String, audio: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
