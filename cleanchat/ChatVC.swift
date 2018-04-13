//
//  ChatVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/13/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ChatVC: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let ref = firebase.child(kMESSAGE)
    
    var loadCount = 0
    var max = 0
    var min = 0
    
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = [] // to load a small amount of messages to avoid user having to wait longer than necessary
    
    var avatarImagesDictionary: NSMutableDictionary? // for saving jsq avatar objects to represent avatar images
    var avatarDictionary: NSMutableDictionary? // dictionary of our image data objects
    
    var members: [String] = [] // chat members - only holds they IDs
    var withUsers: [BackendlessUser] = []
    var currentUser: BackendlessUser = backendless!.userService.currentUser
    var titleName: String?
    
    var chatRoomId: String!
    var isGroup: Bool?
    
    var initialLoadComplete: Bool = false
    var showAvatars = true
    var firstLoad: Bool?
    
    var outgoingMessage: OutgoingMessage?
    
    // put two jsq message bubbles
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = backendless!.userService.currentUser.objectId as String
        self.senderDisplayName = backendless!.userService.currentUser.name as String
        
        self.title = titleName
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        loadMessages()
    }

    // MARK: JSQMessages Data Source functions
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        // incoming or outgoing?
        if data.senderId == backendless!.userService.currentUser.objectId as String {
            // outgoing
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        // setup our message data - access message
        
        let data = messages[indexPath.row]
        
        return data
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // count our number of messages
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == backendless!.userService.currentUser.objectId as String {
            // we're the sender aka outgoing
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        // we're using top to display the timestamp of each message
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
     
        return 0.0
    }
    
   override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        // message status shows on bottom label ie. delivered, read
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        return 0.0
    }
    
    // MARK: - JSQMessages Delegate functions
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // right side of screen
        
        // this func is triggerred when message is selected
        
        if text != "" {
            sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        // pic, audio, location, etc. shows option to user
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = Camera(delegate_: self)
     
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
            camera.presentMultiCamera(target: self, canEdit: true)
        }
       
        let sharePhoto = UIAlertAction(title: "PhotoLibrary", style: .default) { (alert) in
            camera.presentPhotoLibrary(target: self, canEdit: true)
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (alert) in
            camera.presentVideoLibrary(target: self, canEdit: true)
        }
        
        let audioMessage = UIAlertAction(title: "Audio Message", style: .default) { (alert) in
            
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert) in
            
            if self.haveAccessToUserLocation() {
                self.sendMessage(text: nil, date: Date(), picture: nil, location: kLOCATION, video: nil, audio: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(audioMessage)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        // called when user taps load earlier button
        
        // load more messages and refresh collection view
        loadMore(maxNumber: max, minNumber: min)
        self.collectionView!.reloadData()
    }
    
    // MARK: Send Message
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        
        var outgoingMessage: OutgoingMessage?
        
        if let text = text {
            // text message
            outgoingMessage = OutgoingMessage(message: text, senderId: backendless!.userService.currentUser.objectId as String, senderName: backendless!.userService.currentUser.name as String, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        if let pic = picture {
            
            let imageData = UIImageJPEGRepresentation(pic, 0.5)
            let text = kPICTURE
            
            outgoingMessage = OutgoingMessage(message: text, pictureData: imageData! as NSData, senderId: backendless!.userService.currentUser.objectId as String, senderName: backendless!.userService.currentUser.name as String, date: date, status: kDELIVERED, type: kPICTURE)
        }
        
        if let video = video {
            
        }
        
        if let audioPath = audio {
            
        }
        
        if let location = location {
            
            let lat = NSNumber(value: appDelegate.coordinates!.latitude)
            let long = NSNumber(value: appDelegate.coordinates!.longitude)
            
            let text = kLOCATION
            
            outgoingMessage = OutgoingMessage(message: text, latitude: lat, longitude: long, senderId: currentUser.objectId as String, senderName: currentUser.name as String, date: date, status: kDELIVERED, type: kLOCATION)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        // send the message
        outgoingMessage?.sendMessage(chatRoomID: chatRoomId, item: outgoingMessage!.messageDictionary)
        
    }
    
    
    // MARK: Load Messages
    
    func loadMessages() {
        
        let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
        
        ref.child(chatRoomId).observe(.childAdded, with: {
            snapshot in
            
            // update UI
            
            if snapshot.exists() {
                
                let item = (snapshot.value as? NSDictionary)!
                
                if let type = item[kTYPE] as? String {
                    
                    if legitTypes.contains(type) {
                        
                        if self.initialLoadComplete {
                            
                            let incoming = self.insertMessage(item: item)
                            
                            if incoming {
                                
                                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                            }
                            
                            self.finishSendingMessage(animated: true)
                        } else {
                            
                            self.loaded.append(item)
                        }
                    }
                }
            }
        })
        
        ref.child(chatRoomId).observe(.childChanged, with: {
            snapshot in
            
            // update Message
            self.updateMessage(item: snapshot.value as! NSDictionary)
        })
        
        ref.child(chatRoomId).observeSingleEvent(of: .value, with: {
            snapshot in
            
            self.insertMessages()
            self.finishReceivingMessage(animated: false)
            self.initialLoadComplete = true 
        })
    }
    
    func updateMessage(item: NSDictionary) {
        
        for index in 0 ..< objects.count {
            
            let temp = objects[index]
            
            // check if it's the one we want to update
            if item[kMESSAGEID] as! String == temp[kMESSAGEID] as! String {
                objects[index] = item
                self.collectionView!.reloadData()
            }
        }
    }
    
    func insertMessages() {
        
        max = loaded.count - loadCount
        min = max - kNUMBEROFMESSAGES
        
        if min < 0 {
            min = 0
        }
        
        for i in min ..< max {
            
            let item = loaded[i]
            self.insertMessage(item: item)
            loadCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (loadCount != loaded.count)
    }
    
    func loadMore(maxNumber: Int, minNumber: Int) {
        
        max = minNumber - 1
        min = max - kNUMBEROFMESSAGES
        
        if min < 0 {
            min = 0
        }
        
        for i in (min ... max).reversed() {
            let item = loaded[i]
            self.insertNewMessage(item: item)
            loadCount += 1
        }
        
        // check if we should show load earlier button or not
        self.showLoadEarlierMessagesHeader = (loadCount != loaded.count)
    }
    
    func insertNewMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(dictionary: item, chatRoomID: chatRoomId)
        objects.insert(item, at: 0)
        messages.insert(message!, at: 0)
        
        return incoming(item: item)
    }
    
    func insertMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        if (item[kSENDERID] as! String) != backendless!.userService.currentUser.objectId as String {
             
            updateChatStatus(chat: item, chatRoomId: chatRoomId)
        }
        
        let message = incomingMessage.createMessage(dictionary: item, chatRoomID: chatRoomId)
        
        objects.append(item)
        messages.append(message!)
        
        return incoming(item: item)
    }
    
    func incoming(item: NSDictionary) -> Bool {
        
        if backendless!.userService.currentUser.objectId as String == item[kSENDERID] as! String {
            // means it's outgoing
            return false
        } else {
            return true
        }
    }
    
    // MARK: UIImagePickerController delegate functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // return media url of temp. media file
        let video = info[UIImagePickerControllerMediaURL] as? NSURL
        
        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
        
        // the video & pic are nil so we'll pass both in incase either exists
        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Location Access
    
    func haveAccessToUserLocation() -> Bool {
        
        if let _ = appDelegate.locationManager {
            return true
        } else {
            
            ProgressHUD.showError("Please give access to location in Settings.")
            return false
        }
    }
    
    
    
    
 
}
