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
    var _call: SINCall
    
    var callAnswered = false // used to know which UI to display
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate // since we're setting up call in app delegate later on
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _call.delegate = self
        if _call.direction == SINCallDirection.incoming {
            setCallStatusText(text: "")
            showButtons()
            audioController().startPlayingSoundFile(self.pathForSound(soundName: "incoming"), loop: true)
        } else {
            callAnswered = true
            setCallStatusText(text: "Calling...")
            showButtons()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        
        // answered call or is calling
        if callAnswered {
            declineButton.isHidden = true
            hangupButton.isHidden = false
            answerButton.isHidden = true
            
        } else {
            
            declineButton.isHidden = false
            hangupButton.isHidden = true
            answerButton.isHidden = false
        }
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
    
    // MARK: IBActions
    
    @IBAction func declineButton_Pressed(_ sender: UIButton) {
        
    }
    
    @IBAction func endCallButton_Pressed(_ sender: UIButton) {
        
    }
    
    @IBAction func answerButton_Pressed(_ sender: UIButton) {
        
    }

}
