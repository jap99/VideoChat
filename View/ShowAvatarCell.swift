//
//  ShowAvatarCell.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/24/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit
import MobileCoreServices

class ShowAvatarCell: UITableViewCell {

    let userDefaults = UserDefaults.standard
    var avatarSwitchStatus = true
    var firstLoad: Bool?
    
    @IBOutlet weak var showAvatarSwitch: UISwitch!
    

    // MARK: - INIT

    override func awakeFromNib() {
        super.awakeFromNib()
        loadUserDefaults()
    }

    
    // MARK: - IB_ACTIONS
    
    @IBAction func avatarSwitchStatusChanged(_ sender: UISwitch) {
        if sender.isOn {
            avatarSwitchStatus = true
        } else {
            avatarSwitchStatus = false
        }
        saveUserDefaults()
    }
    
    
    // MARK: - ACTIONS
    
    func saveUserDefaults() {   // gets our avatar image state and saves to userdefaults
        userDefaults.set(avatarSwitchStatus, forKey: kAVATARSTATE)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() { // gets our status from user defaults and puts switch in correct position
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        avatarSwitchStatus = userDefaults.bool(forKey: kAVATARSTATE)
        showAvatarSwitch.isOn = avatarSwitchStatus
    }
    
 
    
    
    
}
