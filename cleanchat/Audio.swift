//
//  Audio.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/17/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

class Audio {
    
    var delegate: IQAudioRecorderViewControllerDelegate
    
    init(delegate_: IQAudioRecorderViewControllerDelegate) {
        delegate = delegate_
    }
    
    func presentAudioRecorder(target: UIViewController) {
        
        // once we set the AudioVC we're going to set some parameters
        let vc = IQAudioRecorderViewController()
        vc.delegate = delegate
        vc.title = "Recorder"
        vc.maximumRecordDuration = kAUDIOMAXDURATION
        vc.allowCropping = true
        
        //target is our vc
        target.presentBlurredAudioRecorderViewControllerAnimated(vc)
    }
    
    
    
    
    
    
    
    
}
