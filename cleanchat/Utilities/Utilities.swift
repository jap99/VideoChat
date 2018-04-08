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

