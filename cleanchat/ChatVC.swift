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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

 
}
