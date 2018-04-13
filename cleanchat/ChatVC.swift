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
    
    let loadCount = 0
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
    
    // put two jsq message bubbles
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
    
    func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        return 0.0
    }
    
    // MARK: - JSQMessages Delegate functions
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // right side of screen
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        // pic, audio, location, etc. shows option to user
    }
    
    // MARK: Send Message
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String? video: NSURL?, audio: String?) {
        if let text = text {
            // text message
            
        }
        
        if let pic = picture {
            
        }
        
        if let video = video {
            
        }
        
        if let audioPath = audio {
            
        }
        
        if let location = location {
            
        }
        
        
    }
    
    
    
    
    
    
    
 
}
