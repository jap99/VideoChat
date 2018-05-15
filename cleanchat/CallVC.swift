//
//  CallVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 5/2/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

class CallVC: UIViewController, SINCallDelegate {

    @IBOutlet weak var remoteUserNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var hangupButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    
    var durationTimer: Timer! = nil
    var _call: SINCall!
    
    var callAnswered = false // used to know which UI to display
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate // since we're setting up call in app delegate later on
    
    override func viewWillLayoutSubviews() {
        //callAnswered = true
        showButtons()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _call.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if _call.direction == SINCallDirection.incoming {
            self.declineButton.isHidden = false
            self.hangupButton.isHidden = true
            self.answerButton.isHidden = false
            setCallStatusText(text: "00 : 00")
            //showButtons()
            audioController().startPlayingSoundFile(self.pathForSound(soundName: "incoming"), loop: true)
        } else if _call.direction == SINCallDirection.outgoing {
            //callAnswered = true
            setCallStatusText(text: "Calling...")
            //showButtons()
            self.declineButton.isHidden = true
            self.hangupButton.isHidden = false
            self.answerButton.isHidden = true
        }
        
        self.remoteUserNameLabel.text = "Unknown"
        let id = _call.remoteUserId // accessing our call; remoteUserId will be our b.e. userId - their username
        
        userNameFromCallerID(callerID: id!) { (userName) in
            self.remoteUserNameLabel.text = userName!
        }
    }
    
    
    // Access Sinch audio controller so we can answer phone and speak
    func audioController() -> SINAudioController {
            return appDelegate._client.audioController()
    }
    
    func setCall(call: SINCall) { // need this function because we're passing the call from the app delegate
        _call = call
        _call.delegate = self
    }
    
    
    
    // MARK: UI Update

    func setCallStatusText(text: String) {
        
        statusLabel.text = text // passing our status to our UI
    }
    
    func showButtons() {
        
    }
    
    // MARK: Helper
    
    // returns the path of the sounds to be played
    func pathForSound(soundName: String) -> String {
        
        return Bundle.main.path(forResource: soundName, ofType: ".wav")!
    }
    
    // MARK: Timer
    
    @objc func onDurationTimer() {
        
        let duration = Date().timeIntervalSince(_call.details.establishedTime) // shows the call duration
        updateTimerLabel(seconds: Int(duration))
    }
    
    func updateTimerLabel(seconds: Int) {
        
        let min = String(format: "%02d", (seconds / 60))  // get rid of the zeros after the decimal zeros
        let sec = String(format: "%02d", (seconds % 60))  // leaves two decimal values at the end
        
        setCallStatusText(text: "\(min) : \(sec)")
    }
    
    func startCallDurationTimer() {
        // first every half seconds, it's on our VC, we'll have a selector
        self.durationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.onDurationTimer), userInfo: nil, repeats: true)
    }
    
    func stopCallDurationTimer() {
        
        // check if caller stops call before we could answer it
        if durationTimer != nil { // timer was instantiated
            
            durationTimer.invalidate()
            durationTimer = nil
        }
    }
    
    
    
    // MARK: SINCall Delegate functions
    
        // OUTGOING CALL FUNCTIONS
    func callDidProgress(_ call: SINCall!) {
       
        if call.direction == .incoming {
            self.declineButton.isHidden = false
            self.hangupButton.isHidden = true
            self.answerButton.isHidden = false
       
        } else if call.direction == .outgoing {
            self.declineButton.isHidden = true
            self.hangupButton.isHidden = false
            self.answerButton.isHidden = true
        }
       
        setCallStatusText(text: "Ringing...")
        audioController().startPlayingSoundFile(pathForSound(soundName: "ringback"), loop: true)
 
    }
    
    func callDidEstablish(_ call: SINCall!) {
        
        startCallDurationTimer()
//        self.declineButton.isHidden = false
//        self.hangupButton.isHidden = true
//        self.answerButton.isHidden = false
        self.declineButton.isHidden = true
        self.hangupButton.isHidden = false
        self.answerButton.isHidden = true
        audioController().stopPlayingSoundFile()
    }
    
    func callDidEnd(_ call: SINCall!) {
        
        audioController().stopPlayingSoundFile()
        stopCallDurationTimer()
        dismiss(animated: true, completion: nil)
    }
    
        // INCOMING CALL FUNCTIONS
    
    
    
    
    
    
    // MARK: IBActions
    
    @IBAction func declineButton_Pressed(_ sender: UIButton) {
        _call.hangup()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func endCallButton_Pressed(_ sender: UIButton) {
        _call.hangup()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func answerButton_Pressed(_ sender: UIButton) {
        callAnswered = true
        audioController().stopPlayingSoundFile()
        showButtons()
        _call.answer()
    }

}
