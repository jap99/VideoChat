//
//  RegisterForPush.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/28/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

func updateBackendlessUser(avatarUrl: String) {
    
    var properties = ["Avatar" : avatarUrl]
    
    // for push notification, works only on device
    
//    if let deviceId = backendless!.messagingService.getRegistration().deviceId {
//
//
//        properties = ["Avatar" : avatarUrl, kDEVICEID: deviceId]
//    }
    
    backendless!.userService.currentUser.updateProperties(properties)
    
    // save user to b.e.
    backendless!.userService.update(backendless!.userService.currentUser, response: { (newUser) in
        print("USER UPDATED SUCCESSFULLY WITH FB")
    }) { (fault) in
        
        print("COULDN't UPDATE USER: \(fault?.detail!)")
    }
    
}








