//
//  Utilities.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/22/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

// https://developer.apple.com/documentation/foundation/dateformatter

import Foundation

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

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

extension UIImage {
    func imageWithColor(color: UIColor) -> UIImage? {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}


let pinkBorder = UIColor(red: 236/255, green: 14/255, blue: 128/255, alpha: 1).cgColor
let pinkColor = UIColor(red: 236/255, green: 14/255, blue: 128/255, alpha: 1)
let lightBlue = UIColor(red: 0/255, green: 38/255, blue: 144/255, alpha: 1)//UIColor(red: 0/255, green: 38/255, blue: 212/255, alpha: 1)    //UIColor(red: 50/255, green: 142/255, blue: 225/255, alpha: 1)
let lead = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)
let snow = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
