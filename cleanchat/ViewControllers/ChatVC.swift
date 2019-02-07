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
    var messages = [JSQMessage]()
    var objects = [NSDictionary]()
    var loaded = [NSDictionary]() // to load a small amount of messages to avoid user having to wait longer than necessary
    var avatarImagesDictionary: NSMutableDictionary? // for saving jsq avatar objects to represent avatar images
    var avatarDictionary: NSMutableDictionary? // dictionary of our image data objects
    var members = [String]() // chat members - only holds they IDs
    var withUsers = [BackendlessUser]()
    var currentUser: BackendlessUser = backendless!.userService.currentUser
    var titleName: String?
    var chatRoomId: String!
    var isGroup: Bool?
    var initialLoadComplete = false
    var showAvatars = true
    var firstLoad: Bool?
    var outgoingMessage: OutgoingMessage?
    // put two jsq message bubbles
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    
    // MARK: - INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarDictionary = [:]
        self.senderId = backendless!.userService.currentUser.objectId as String
        self.senderDisplayName = backendless!.userService.currentUser.name as String
        self.title = titleName
        self.navigationController?.navigationBar.tintColor = darkBlue
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearRecentCounter(chatRoomID: chatRoomId)
        loadUserDefaults()
        setBackgroundColor()
        updateUI()
        loadMessages()
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        clearRecentCounter(chatRoomID: chatRoomId)
        // remove our observers because we no longer need to see any changes
        ref.removeAllObservers()
    }
    

    // MARK: - ACTIONS
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        var outgoingMessage: OutgoingMessage?
        if let text = text {
            // text message
            // encrypt
            let encryptedText = encryptText(chatRoomID: chatRoomId, text: text)
            outgoingMessage = OutgoingMessage(message: encryptedText, senderId: backendless!.userService.currentUser.objectId as String, senderName: backendless!.userService.currentUser.name as String, date: date, status: kDELIVERED, type: kTEXT)
        }
        if let pic = picture {
            //            let imageData = UIImageJPEGRepresentation(pic, 0.5)
            let imageData = pic.jpegData(compressionQuality: 0.5)
            //encrypt
            let encryptedText = encryptText(chatRoomID: chatRoomId, text: kPICTURE)
            outgoingMessage = OutgoingMessage(message: encryptedText, pictureData: imageData! as NSData, senderId: backendless!.userService.currentUser.objectId as String, senderName: backendless!.userService.currentUser.name as String, date: date, status: kDELIVERED, type: kPICTURE)
        }
        if let video = video {
            let videoData = NSData(contentsOfFile: video.path!)
            // create thumbnail
            let picture = videoThumbnail(video: video)
            // make square image
            let squared = squareImage(image: picture, size: 320)
            // create data from our image
            //            let dataThumbnail = UIImageJPEGRepresentation(squared, 0.3)
            let dataThumbnail = squared.jpegData(compressionQuality: 0.3)
            //upload to backendless
            uploadVideo(video: videoData!, thumbnail: dataThumbnail! as NSData) { (videoLink, thumbnailLink) in
                // encrypt
                let encryptedText = encryptText(chatRoomID: self.chatRoomId, text: kVIDEO)
                // create ougoingMessage
                outgoingMessage = OutgoingMessage(message: encryptedText, video: videoLink!, thumbnail: thumbnailLink!, senderId: self.currentUser.objectId as String, senderName: self.currentUser.name as String, date: date, status: kDELIVERED, type: kVIDEO)
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, item: outgoingMessage!.messageDictionary)
            }
            return
        } // here's what happens when we send an audio file
        if let audioPath = audio {
            uploadAudio(audioPath: audioPath) { (audioLink) in
                //save the audio link we get back form our callback function in firebase
                //encrypt
                let encryptedText = encryptText(chatRoomID: self.chatRoomId, text: kAUDIO)
                // create the message
                outgoingMessage = OutgoingMessage(message: encryptedText, audio: audioLink!, senderId: self.currentUser.objectId as String, senderName: self.currentUser.name as String, date: date, status: kDELIVERED, type: kAUDIO)
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                outgoingMessage!.sendMessage(chatRoomID: self.chatRoomId, item: outgoingMessage!.messageDictionary)
            }
            return
        } // send location
        if location != nil {
            let lat = NSNumber(value: appDelegate.coordinates!.latitude)
            let long = NSNumber(value: appDelegate.coordinates!.longitude)
            // encrypt
            let encryptedText = encryptText(chatRoomID: chatRoomId, text: kLOCATION)
            outgoingMessage = OutgoingMessage(message: encryptedText, latitude: lat, longitude: long, senderId: currentUser.objectId as String, senderName: currentUser.name as String, date: date, status: kDELIVERED, type: kLOCATION)
        }
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        // send the message
        outgoingMessage?.sendMessage(chatRoomID: chatRoomId, item: outgoingMessage!.messageDictionary)
    }
    
    func loadMessages() {
        let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
        ref.child(chatRoomId).observe(.childAdded, with: { snapshot in
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
        ref.child(chatRoomId).observe(.childChanged, with: { snapshot in
            // update Message
            self.updateMessage(item: snapshot.value as! NSDictionary)
        })
        ref.child(chatRoomId).observeSingleEvent(of: .value, with: { snapshot in
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
    
    func updateUI() {
        // display avatars and display call button if
        if members.count < 3 {
            // display call button
            let callButton = UIBarButtonItem(image: UIImage(named: "Phone"), style: .plain, target: self, action: #selector(ChatVC.callBarButton_Pressed))
            self.navigationItem.rightBarButtonItem = callButton
        } // otherwise don't because we don't have a conference chat
        getWithUserFromRecent(members: members) { (withUsers) in
            // get all users and set it to our withUsers array
            self.withUsers = withUsers
            // get Avatars - checks if we want to show our avatars
            self.getAvatars()
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
            // once we finish with our avatarImagesDictionary we create Avatars
            self.createAvatars(avatars: self.avatarImagesDictionary)
        }
    }
    
    func createAvatars(avatars: NSMutableDictionary?) {
        // first need to have our default avatar
        let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        if let avat = avatars {
            for userId in members {
                // get all their avatars
                if let avatarImage = avat[userId] {
                    let jsqAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: avatarImage as! Data), diameter: 70)
                    self.avatarDictionary!.setValue(jsqAvatar, forKey: userId)
                } else { // in case we don't have an avatar
                    self.avatarDictionary!.setValue(defaultAvatar, forKey: userId)
                }
            }
            self.collectionView.reloadData()
            self.view.setNeedsLayout()
        }
    }
    
    
    func avatarImageFromBackendlessUser(user: BackendlessUser) {
        // return avatar image's link
        if let imageLink = user.getProperty("Avatar") {
            getAvatarFromURL(url: imageLink as! String, result: { (image) in // downloads the image if we have a link, then saves in our avatarImagesDictionary
                //                let imageData = UIImageJPEGRepresentation(image!, 0.5)
                let imageData = image!.jpegData(compressionQuality: 0.5)
                if self.avatarImagesDictionary != nil {
                    // remove object then set the updated one
                    self.avatarImagesDictionary!.removeObject(forKey: user.objectId!)
                    self.avatarImagesDictionary!.setObject(imageData!, forKey: user.objectId!)
                } else {
                    // create new dictionary and put the objects inside
                    self.avatarImagesDictionary = [user.objectId! : imageData!]
                }
                // create avatars
                self.createAvatars(avatars: self.avatarImagesDictionary)
            })
        }
    }
    
    
    func getWithUserFromRecent(members: [String], result: @escaping (_ withUsers: [BackendlessUser]) -> Void) {
        var receivedMembers: [BackendlessUser] = []
        for userId in members {
            // get user avatar
            if userId != currentUser.objectId as String {
                let whereClause = "objectId = '\(userId)'"
                let dataQuery = DataQueryBuilder()
                dataQuery!.setWhereClause(whereClause)
                let dataStore = backendless!.persistenceService.of(BackendlessUser.ofClass())
                dataStore!.find(dataQuery, response: { (users) in
                    // when we get our user back
                    let withUser = users?.first as! BackendlessUser
                    // add user to received members
                    receivedMembers.append(withUser)
                    // check if we received all members from our chat
                    if receivedMembers.count == (members.count - 1) {
                        // receivedMembers doesn't include current user; members does
                        result(receivedMembers)
                    }
                }, error: { (fault) in
                    ProgressHUD.showError("Couldn't get chat users: \(fault!.detail!)")
                })
            }
        }
    }
    
    // MARK: - USER_DEFAULTS
    
    func loadUserDefaults() { // check if it's the first time we're running our app
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        // check if we have a value in our userDefaults
        if !firstLoad! { // if not nil
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(showAvatars, forKey: kAVATARSTATE)
            // set background color - white by default
            userDefaults.set(1.0, forKey: kRED)
            userDefaults.set(1.0, forKey: kGREEN)
            userDefaults.set(1.0, forKey: kBLUE)
            // save
            userDefaults.synchronize()
        } // if it's not our first run it'll just get our avatarState
        showAvatars = userDefaults.bool(forKey: kAVATARSTATE)
    }
    
    func setBackgroundColor() { // get bg from userdefaults and set it to chat bg color
        self.collectionView.backgroundColor = UIColor(red: CGFloat(userDefaults.float(forKey: kRED)), green: CGFloat(userDefaults.float(forKey: kGREEN)), blue: CGFloat(userDefaults.float(forKey: kBLUE)), alpha: 1.0)
    }

    
    // MARK: - IMAGE_PICKER_CONTROLLER_DELEGATE
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // return media url of temp. media file
//        let video = info[UIImagePickerControllerMediaURL] as? NSURL
//        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
//        // the video & pic are nil so we'll pass both in incase either exists
//        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: LOCATION ACCESS
    
    func haveAccessToUserLocation() -> Bool {
        if let _ = appDelegate.locationManager {
            return true
        } else {
            ProgressHUD.showError("Please give access to location in Settings.")
            return false
        }
    }
    
    
    // MARK: IQ_AUDIO_RECORDER_DELEGATE
  
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
    
    // MARK: VOIP
    
    func callClient() -> SINCallClient {
        return appDelegate._client.call()
    }
    
    @objc func callBarButton_Pressed() {
        let userToCallId = withUsers.first!.objectId as String // first object id we want to call
        let call = callClient().callUser(withId: userToCallId)
        
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallVC-ID") as! CallVC
        callVC._call = call
        self.present(callVC, animated: true, completion: nil)
    }
    
    
    // MARK: JSQ_MESSAGES
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count   // count our number of messages
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let data = messages[indexPath.row]      // setup our message data - access message
        return data
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // this is the color of the font inside the chat bubble
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let data = messages[indexPath.row]
        if data.senderId == backendless!.userService.currentUser.objectId as String {
            cell.textView?.textColor = UIColor.white // outgoing
        } else {
            cell.textView?.textColor = UIColor.black // incoming
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        if data.senderId == backendless!.userService.currentUser.objectId as String {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {        // we're using top to display the timestamp of each message
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
        // message status shows on bottom label ie. delivered, read     // displayed for the last message only
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        var avatar: JSQMessageAvatarImageDataSource     // create an avatar
        // check if user has avatar saved in dictionary for each user
        if let testAvatar = avatarDictionary!.object(forKey: message.senderId) {
            avatar = testAvatar as! JSQMessageAvatarImageDataSource
        } else {
            avatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        }
        return avatar
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        // called when user taps load earlier button     // load more messages and refresh collection view
        loadMore(maxNumber: max, minNumber: min)
        self.collectionView!.reloadData()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        // called when we tap on a message          // to understand what kind of message we're tapping
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
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // right side of screen         // this func is triggerred when message is selected
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
    
    
    
}
