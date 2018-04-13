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
    
    func createMessage(dictionary: NSDictionary, chatRoomID: String) -> JSQMessage? {
        
        var message: JSQMessage?
        let type = dictionary[kTYPE] as? String
        
        if type == kTEXT {
            // text message
            message = createTextMessage(item: dictionary, chatRoomID: chatRoomID)
        }
        
        if type == kLOCATION {
            
        }
        
        if type == kPICTURE {
            
            message = createPictureMessage(item: dictionary)
        }
        
        if type == kVIDEO {
            
        }
    
        if type == kAUDIO {
            
        }
        
        if let mes = message {
            // if we've set the message in a previous func we return it here
            return message!
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
    
    func createPictureMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        
        // needed to present media
        let mediaItem = JSQPhotoMediaItem(image: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId: userId!)
        
        // check image and convert data to uiimage
        imageFromData(item: item) { (image) in
            
            mediaItem?.image = image
            self.collectionView.reloadData()
            
        }
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    
    // MARK: Helper functions
    
    func imageFromData(item: NSDictionary, result: (_ image: UIImage?) -> Void) {
        
        var image: UIImage?
        
        //decode the text from firebase
        let decodedData = NSData(base64Encoded: (item[kPICTURE] as? String)!, options: NSData.Base64DecodingOptions(rawValue: 0))
        
        image = UIImage(data: decodedData! as Data)
        result(image)
    }
    
    func returnOutgoingStatusFromUser(senderId: String) -> Bool {
        
        // check if media is incoming or outgoing
        
        if senderId == backendless!.userService.currentUser.objectId as String {
            
            // outgoing
            return true
        } else {
            
            // incoming
            return false
        }
    }
    
    
    
    
    
}
