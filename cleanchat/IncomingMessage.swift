//
//  IncomingMessage.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/13/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

public class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(dictionary: NSDictionary, chatRoomID: String) -> JSQMessage {
        
        var message: JSQMessage?
        let type = dictionary[kTYPE] as? String
        
        if type == kTEXT {
            // text message
            createTextMessage(item: dictionary, chatRoomID: chatRoomID)
        }
        
        if type == kLOCATION {
            
        }
        
        if type == kPICTURE {
            
        }
        
        if type == kVIDEO {
            
        }
    
        if type == kAUDIO {
            
        }
        
        if let mes = message {
            // if we've set the message in a previous func we return it here
            return message
        }
    
        return nil
    }
    
    
    func createTextMessage(item: NSDictionary, chatRoomID: String) -> JSQMessage {
        
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        
        // display msg
        let text = (item[kMESSAGE] as? String)!
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
        
    }
    
    
}
