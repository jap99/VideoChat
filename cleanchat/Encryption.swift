//
//  Encryption.swift
//  cleanchat
//
//  Created by Javid Poornasir on 5/2/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation


// ENCRYPT TEXT MESSAGE

func encryptText(chatRoomID: String, text: String) -> String {
    let data = text.data(using: String.Encoding.utf8) // creates data from our text
    // encrypt
    let encryptedData = RNCryptor.encrypt(data: data!, withPassword: chatRoomID) // must have the chatRoomID in order to read the msg
    return encryptedData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
}


// DECRYPT TEXT MESSAGE

func decryptText(chatRoomID: String, text: String) -> String {
    let decryptor = RNCryptor.Decryptor(password: chatRoomID)
    let encryptedData = NSData(base64Encoded: text, options: NSData.Base64DecodingOptions(rawValue: 0))
    var message: NSString = ""
    // decrypt
    do {
        let decryptedData = try decryptor.decrypt(data: encryptedData! as Data)
        message = NSString(data: decryptedData, encoding: String.Encoding.utf8.rawValue)!
    } catch {
        print("ERROR DECODING TEXT: \(error.localizedDescription)")
    }
    return message as String
}
