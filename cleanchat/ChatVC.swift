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

 
}
