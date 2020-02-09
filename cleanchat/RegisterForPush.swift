//
//  RegisterForPush.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/28/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

// TODO - put in a class


func registerUserDeviceID(user: BackendlessUser?) {
    // check if we have a deviceID
    let deviceRegistration: DeviceRegistration = (backendless?.messaging.currentDevice())!
    let deviceId: String = deviceRegistration.deviceId // represents the deviceID in both USERS & DEVICE REGISTRATION when user logs in w email; haven't tested w facebook yet
    backendless?.messagingService.getRegistration(deviceId) // DEVICE REGISTRATION's deviceId column
    let properties = [kDEVICEID: deviceId]
    backendless?.userService?.currentUser?.updateProperties(properties)
    backendless?.userService?.update(backendless?.userService?.currentUser!, response: { (newUser) in
        print("USER UPDATED SUCCESSFULLY IS REGISTERUSERDEVICEID FUNC")
    }) { (error) in
        print("COULD NOT UPDATE USER IN REGISTERUSERDEVICEID FUNC \(String(describing: error!.detail))")
    }
//    if backendless!.messagingService.getRegistration(deviceId) != nil { // DEVICE REGISTRATION's deviceId column
//        let properties = [kDEVICEID: deviceId]
//        backendless!.userService.currentUser!.updateProperties(properties)
//        backendless!.userService.update(backendless!.userService.currentUser, response: { (newUser) in
//            print("USER UPDATED SUCCESSFULLY IS REGISTERUSERDEVICEID FUNC")
//        }) { (error) in
//            print("COULD NOT UPDATE USER IN REGISTERUSERDEVICEID FUNC \(String(describing: error!.detail))")
//        }
//    }
}

func removeDeviceIdFromUser() {
    let properties = [kDEVICEID: ""]
    if let currentUser = backendless?.userService?.currentUser {
        currentUser.updateProperties(properties)
        backendless?.userService.update(currentUser, response: { (newUser) in
            print("REMOVED DEVICE ID IN BACKENDLESS")
        }) { (error) in
            print(" ERROR REMOVING DEVICE FROM USER IN BACKENDLESS\(String(describing: error!.detail))")
        }
    }
}


func updateBackendlessUser(avatarUrl: String) {
    var properties = ["Avatar" : avatarUrl]
    // for push notification, works only on device
    if let deviceRegistration: DeviceRegistration = (backendless?.messaging.currentDevice()) {
        let deviceId: String = deviceRegistration.deviceId
        backendless?.messagingService.getRegistration(deviceId)
        properties = ["Avatar" : avatarUrl, kDEVICEID: deviceId]
        backendless?.userService?.currentUser?.updateProperties(properties)
        // save user to b.e.
        backendless?.userService?.update(backendless?.userService?.currentUser, response: { (_) in
            print("USER UPDATED SUCCESSFULLY WITH FB")
        }) { (fault) in
            if let fault = fault {
                print("COULDN't UPDATE USER: \(fault.detail!)")
            }
        }
//        if backendless?.messagingService.getRegistration(deviceId) != nil {
//            properties = ["Avatar" : avatarUrl, kDEVICEID: deviceId]
//            backendless?.userService?.currentUser?.updateProperties(properties)
//            // save user to b.e.
//            backendless?.userService?.update(backendless!.userService.currentUser, response: { (_) in
//                print("USER UPDATED SUCCESSFULLY WITH FB")
//            }) { (fault) in
//                if let fault = fault {
//                    print("COULDN't UPDATE USER: \(fault.detail!)")
//                }
//            }
//        }
    }
}








