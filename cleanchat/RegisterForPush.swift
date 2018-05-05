//
//  RegisterForPush.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/28/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

func registerUserDeviceID(user: BackendlessUser?) {
    
    // check if we have a deviceID
    
    let deviceRegistration: DeviceRegistration = (backendless?.messaging.currentDevice())!
    let deviceId: String = deviceRegistration.deviceId
    
    if backendless!.messagingService.getRegistration(deviceId) != nil {
        
        let properties = [kDEVICEID: deviceId]
        
        backendless!.userService.currentUser!.updateProperties(properties)
        
        backendless!.userService.update(backendless!.userService.currentUser, response: { (newUser) in
            print("USER UPDATED SUCCESSFULLY IS REGISTERUSERDEVICEID FUNC")
        }) { (error) in
            print("COULD NOT UPDATE USER IN REGISTERUSERDEVICEID FUNC \(error!.detail)")
        }
    }
}

func removeDeviceIdFromUser() {
    
    let properties = [kDEVICEID: ""]
    
    backendless!.userService.currentUser!.updateProperties(properties)
    
    backendless!.userService.update(backendless!.userService.currentUser, response: { (newUser) in
        print("REMOVED DEVICE ID IN BACKENDLESS")
    }) { (error) in
        print(" ERROR REMOVING DEVICE FROM USER IN BACKENDLESS\(error!.detail)")
    }
}


func updateBackendlessUser(avatarUrl: String) {
    
    var properties = ["Avatar" : avatarUrl]
    
    // for push notification, works only on device
    
    let deviceRegistration: DeviceRegistration = (backendless?.messaging.currentDevice())!
    let deviceId: String = deviceRegistration.deviceId
    
    if backendless!.messagingService.getRegistration(deviceId) != nil {


        properties = ["Avatar" : avatarUrl, kDEVICEID: deviceId]
    }
    
    backendless!.userService.currentUser.updateProperties(properties)
    
    // save user to b.e.
    backendless!.userService.update(backendless!.userService.currentUser, response: { (newUser) in
        print("USER UPDATED SUCCESSFULLY WITH FB")
    }) { (fault) in
        
        print("COULDN't UPDATE USER: \(fault!.detail!)")
    }
    
}








