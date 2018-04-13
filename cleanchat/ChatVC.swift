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
            cell.textView.textColor = .white
        } else {
            cell.textView?.textColor = .black
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
    }
    
    // MARK: Send Message
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        
        var outgoingMessage: OutgoingMessage?
        
        if let text = text {
            // text message
            outgoingMessage = OutgoingMessage(message: text, senderId: backendless!.userService.currentUser.objectId as String, senderName: backendless!.userService.currentUser.name as String, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        if let pic = picture {
            
        }
        
        if let video = video {
            
        }
        
        if let audioPath = audio {
            
        }
        
        if let location = location {
            
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
        })
        
        ref.child(chatRoomId).observeSingleEvent(of: .value, with: {
            snapshot in
            
            self.insertMessages()
            self.finishReceivingMessage(animated: false)
            self.initialLoadComplete = true 
        })
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
    
    func insertMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        if (item[kSENDERID] as! String) != backendless!.userService.currentUser.objectId as String {
            
            // update status
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
 
}
