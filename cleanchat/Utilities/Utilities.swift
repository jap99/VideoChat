//
//  Utilities.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/22/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

// https://developer.apple.com/documentation/foundation/dateformatter

import Foundation

private let dateFormat = "yyyyMMddHHmmss"
// private let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

func dateFormatter() -> DateFormatter {
    
    let dateFormatter = DateFormatter()
   // DateFormatter.dateFormatter = dateFormat
    
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = dateFormat
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    return dateFormatter
}

func userNameFromCallerID(callerID: String, result: @escaping (_ callerName: String?) -> Void) {
    
    // acess our b.e. and find the user with the objectId aka callerId that's been passed to us
    let whereClause = "objectId = '\(callerID)'"
    let dq = DataQueryBuilder()
    dq?.setWhereClause(whereClause)
    
    let dataStore = backendless!.persistenceService.of(BackendlessUser.ofClass())
    dataStore!.find(dq, response: { users in
        
        let user = users!.first as! BackendlessUser
        result(user.name as String)
        
    }, error: {
        fault in
        
        ProgressHUD.showError("COULDNT GET USERNAME THAT IS CALLING: \(fault!.detail!)")
    })
    
}
