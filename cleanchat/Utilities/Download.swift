//
//  Download.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/6/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

// Avatar - Download & Upload


// Download
func getAvatarFromURL(url: String, result: @escaping (_ image: UIImage?) -> Void) {
    
    let url = NSURL(string: url)
    
    // create queue so avatar isn't downloaded on main thread
    let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
    
    downloadQueue.async {
        
        let data = NSData(contentsOf: url! as URL)
        let image: UIImage!
        
        if data != nil {
            
            image = UIImage(data: data! as Data)
            
            DispatchQueue.main.async {
                
                result(image!)
            }
        }
    }
}

func uploadAvatar(image: UIImage, result: @escaping (_ imageLink: String?) -> Void) {
    
    // returning the link of where the image is uploaded
    
    // need to convert image to data in order to upload
    let imageData = UIImageJPEGRepresentation(image, 0.5)
    
    
    let dateString = dateFormatter().string(from: Date())
    
    // Specify the folder Img
    let fileName = "Img" + dateString + ".jpeg"
    
    backendless!.fileService.saveFile(fileName, content: imageData, response: { (file) in
        
        result(file?.fileURL)
        
    }) { (fault) in
        
        ProgressHUD.showError("Couldn't upload avatar image: \(fault!.detail)")
    }
    
}
