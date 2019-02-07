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
    
    
    // MARK: - INIT
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    
    // MARK: - ACTIONS
    
    func createMessage(dictionary: NSDictionary, chatRoomID: String) -> JSQMessage? {
        var message: JSQMessage?
        let type = dictionary[kTYPE] as? String
        if type == kTEXT { // text message
            message = createTextMessage(item: dictionary, chatRoomID: chatRoomID)
        }
        if type == kLOCATION {
            message = createLocationMessage(item: dictionary)
        }
        if type == kPICTURE {
            message = createPictureMessage(item: dictionary)
        }
        if type == kVIDEO { // call our func when we're getting a video message
            message = createVideoMessage(item: dictionary)
        }
        if type == kAUDIO {
            message = createAudioMessage(item: dictionary)
        }
        if message != nil { // if we've set the message in a previous func we return it here
            return message!
        }
        return nil
    }
    
    func createAudioMessage(item: NSDictionary) -> JSQMessage {
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        // get audio url
        let audioURL = NSURL(fileURLWithPath: item[kAUDIO] as! String)
        let mediaItem = AudioMessage(withFileURL: audioURL, maskOutgoing: returnOutgoingStatusFromUser(senderId: userId!))
        // now that we have our audio message instantiated we can start downloading our audio
        downloadAudio(audioUrl: item[kAUDIO] as! String) { (fileName) in
            // access our local directory because as soon as we download it we want to save it there
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(filename: fileName))
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            self.collectionView.reloadData()
        }
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date!, media: mediaItem)
    }
    
    func createVideoMessage(item: NSDictionary) -> JSQMessage {
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        let videoURL = NSURL(fileURLWithPath: item[kVIDEO] as! String)
        let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: returnOutgoingStatusFromUser(senderId: userId!))
        downloadVideo(videoUrl: item[kVIDEO] as! String) { (isReadyToPlay, fileName) in
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(filename: fileName))
            // download thumbnail
            let thumbnailURL = NSURL(string: item[kTHUMBNAIL] as! String)
            let data = NSData(contentsOf: thumbnailURL! as URL)
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            //mediaItem.image = UIImage(data: data as! Data)
            mediaItem.image = UIImage(data: data! as Data)
            self.collectionView.reloadData()
        }
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    func createTextMessage(item: NSDictionary, chatRoomID: String) -> JSQMessage {
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        let text = (item[kMESSAGE] as? String)!
        // decrypt text
        let decryptedText = decryptText(chatRoomID: chatRoomID, text: text)
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: decryptedText)
    }
    
    func createPictureMessage(item: NSDictionary) -> JSQMessage {
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        // needed to present media
        let mediaItem = JSQPhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId: userId!)
        imageFromData(item: item) { (image) in  // check image and convert data to uiimage
            mediaItem?.image = image
            self.collectionView.reloadData()
        }
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func createLocationMessage(item: NSDictionary) -> JSQMessage {  // call this function as soon as we receive a location message
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        let lat = item[kLATITUDE] as? Double
        let lon = item[kLONGITUDE] as? Double
        let mediaItem = JSQLocationMediaItem(location: nil)
        // set location once we get item
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId: userId!)
        let location = CLLocation(latitude: lat!, longitude: lon!)
        mediaItem?.setLocation(location, withCompletionHandler: {
            self.collectionView.reloadData()
        })
        return JSQMessage(senderId: userId, displayName: name, media: mediaItem)
    }
    
    
    // MARK: - HELPER FUNCTIONS
    
    func imageFromData(item: NSDictionary, result: (_ image: UIImage?) -> Void) {
        var image: UIImage?         //decode the text from firebase
        let decodedData = NSData(base64Encoded: (item[kPICTURE] as? String)!, options: NSData.Base64DecodingOptions(rawValue: 0))
        image = UIImage(data: decodedData! as Data)
        result(image)
    }
    
    func returnOutgoingStatusFromUser(senderId: String) -> Bool {        // check if media is incoming or outgoing
        if senderId == backendless!.userService.currentUser.objectId as String {    // outgoing
            return true
        } else {            // incoming
            return false
        }
    }
    
    
    
    
    
}
