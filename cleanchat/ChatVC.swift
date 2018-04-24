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

class ChatVC: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, IQAudioRecorderViewControllerDelegate {
    
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
        
        avatarDictionary = [:]
        self.senderId = backendless!.userService.currentUser.objectId as String
        self.senderDisplayName = backendless!.userService.currentUser.name as String
        
        self.title = titleName
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        updateUI()
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
        
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        // message status shows on bottom label ie. delivered, read
        
        // displayed for the last message only
        let message = objects[indexPath.row]
        let status = message[kSTATUS] as! String
        if indexPath.row == (messages.count - 1) {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if outgoing(item: objects[indexPath.row]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
        
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
        
        let cameraVC = Camera(delegate_: self)
        let audioVC = Audio(delegate_: self)
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
            cameraVC.presentMultiCamera(target: self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "PhotoLibrary", style: .default) { (alert) in
            cameraVC.presentPhotoLibrary(target: self, canEdit: true)
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (alert) in
            cameraVC.presentVideoLibrary(target: self, canEdit: true)
        }
        
        let audioMessage = UIAlertAction(title: "Audio Message", style: .default) { (alert) in
            audioVC.presentAudioRecorder(target: self)
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
            
            let videoData = NSData(contentsOfFile: video.path!)
            
            // create thumbnail
            let picture = videoThumbnail(video: video)
            
            // make square image
            let squared = squareImage(image: picture, size: 320)
            
            // create data from our image
            let dataThumbnail = UIImageJPEGRepresentation(squared, 0.3)
            
            //upload to backendless
            uploadVideo(video: videoData!, thumbnail: dataThumbnail! as NSData) { (videoLink, thumbnailLink) in
                
                let text = kVIDEO
                
                // create ougoingMessage
                outgoingMessage = OutgoingMessage(message: text, video: videoLink!, thumbnail: thumbnailLink!, senderId: self.currentUser.objectId as String, senderName: self.currentUser.name as String, date: date, status: kDELIVERED, type: kVIDEO)
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
                outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, item: outgoingMessage!.messageDictionary)
            }
            return
        }
        
        // here's what happens when we send an audio file
        if let audioPath = audio {
            
            uploadAudio(audioPath: audioPath) { (audioLink) in
                //save the audio link we get back form our callback function in firebase
                let text = kAUDIO
                
                // create the message
                outgoingMessage = OutgoingMessage(message: text, audio: audioLink!, senderId: self.currentUser.objectId as String, senderName: self.currentUser.name as String, date: date, status: kDELIVERED, type: kAUDIO)
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
                outgoingMessage!.sendMessage(chatRoomID: self.chatRoomId, item: outgoingMessage!.messageDictionary)
                
            }
            return
        }
        
        // send location
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
    
    // MARK: Responds to collection view tap events
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        // called when we tap on a message
        
        // to understand what kind of message we're tapping
        let object = objects[indexPath.row]
        
        // check what kind of message we tapped on
        if object[kTYPE] as! String == kPICTURE {
            let message = messages[indexPath.row] // got our jsq message
            let mediaItem = message.media as! JSQPhotoMediaItem
            
            // get the photo out of the media item
            // pass in the photos we want IDMPhoto to display
            let photos = IDMPhoto.photos(withImages: [mediaItem.image])
            
            let browser = IDMPhotoBrowser(photos: photos)
            
            // display our idm photo browser
            self.present(browser!, animated: true, completion: nil)
            
            
        }
        
        if object[kTYPE] as! String == kLOCATION {
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQLocationMediaItem
            
            // instantia our mapVC
            let mapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC-ID") as! MapVC
            
            mapVC.location = mediaItem.location
            self.present(mapVC, animated: true, completion: nil)
        }
        
        if object[kTYPE] as! String == kVIDEO {
            let message = messages[indexPath.row]
            let mediaItem = message.media as! VideoMessage
            
            let player = AVPlayer(url: mediaItem.fileURL! as URL)
            let moviePlayer = AVPlayerViewController()
            moviePlayer.player = player
            
            self.present(moviePlayer, animated: true, completion: {
                
                // play movie as soon as movie player's presented
                moviePlayer.player!.play()
            })
        }
        
        if object[kTYPE] as! String == kAUDIO {
           
            let message = messages[indexPath.row]
            let mediaItem = message.media as! AudioMessage
            
            let player = AVPlayer(url: mediaItem.fileURL! as URL)
            let moviePlayer = AVPlayerViewController()
            moviePlayer.player = player
            
            self.present(moviePlayer, animated: true, completion: {
                
                // play movie as soon as movie player's presented
                moviePlayer.player!.play()
            })
        }
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
            print("PRINTING I : \(i)")
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
    
    func outgoing(item: NSDictionary) -> Bool {
        if currentUser.objectId as String == item[kSENDERID] as! String {
            return true
        } else {
            return false
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
    
    // MARK: IQAudioRecorder Delegate
    
  
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        
        controller.dismiss(animated: true, completion: nil)
        // send a message with our audiofile name
        self.sendMessage(text: nil, date: Date(), picture: nil, location: nil, video: nil, audio: filePath)
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        let vc = controller
        
        vc.dismiss(animated: true, completion: nil)
        print("cancelled audio")
    }
    
    
    // MARK: Helper functions
    
    func updateUI() {
        
        // display avatars and display call button if
        if members.count < 3 {
            
            // display call button
        } // otherwise don't because we don't have a conference chat
  
        getWithUserFromRecent(members: members) { (withUsers) in
            
            // withUsers is an array of BackendlessUsers
            
            self.withUsers = withUsers
            
            // get Avatars
        }
    
    }
    
    func getAvatars() {
        
        // check if we want to show avatars
        if showAvatars {
            
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
            
            avatarImageFromBackendlessUser(user: currentUser) // gets our current user's avatar
            for user in withUsers { //  now get em for all other users
                avatarImageFromBackendlessUser(user: user)
            }
            
            // create Avatars
        }
        
        
    }
    
    
    func avatarImageFromBackendlessUser(user: BackendlessUser) {
        
        // return avatar image from Bakcendless User
        if let imageLink = user.getProperty("Avatar") {
            
            getAvatarFromURL(url: imageLink as! String) { (image) in
                
                let imageData = UIImageJPEGRepresentation(image!, 0.5)
                
                if self.avatarImagesDictionary != nil {
                     // add objects to dict
                    
                    self.avatarImagesDictionary!.removeObject(forKey: user.objectId!)
                    
                    // now set the updated one
                    self.avatarImagesDictionary!.setObject(imageData!, forKey: user.objectId!)
                } else {
                    self.avatarImagesDictionary = [user.objectId! : imageData!]
                }
                
                // create avatars
            })
        }
    }
    
    
    func getWithUserFromRecent(members: [String], result: @escaping (_ withUsers: [BackendlessUser]) -> Void) {
        
        var receivedMembers: [BackendlessUser] = []
        
        for userId in members {
            // get user avatar
            
            if userId != currentUser.objectId as String {
                
                let whereClause = "objectId = '\(userId)'"
                let dataQuery = BackendlessDataQuery()
                dataQuery.whereClause = whereClause
                
                let dataStore = backendless!.persistenceService.of(BackendlessUser.ofClass())
                dataStore!.find(dataQuery, response: { (users) in
                    
                    // when we get our user back
                    let withUser = users?.data.first as! BackendlessUser
                    
                    // add user to received members
                    receivedMembers.append(withUser)
                    
                    // check if we received all members from our chat
                    if receivedMembers.count == (members.count - 1) {
                        
                        // receivedMembers doesn't include current user; members does
                        result(receivedMembers)
                    }
                    
                }, error: { (fault) in
                    
                    ProgressHUD.showError("Couldn't get chat users: \(fault!.detail)")
                })
            }
        }
        
        
    }
    
    
    
    
    
    
    
}
