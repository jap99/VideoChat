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

func uploadVideo(video: NSData, thumbnail: NSData, result: @escaping (_ videoLink: String?, _ thumbnailLink: String?) -> Void) {
    
    let dateString = dateFormatter().string(from: Date())
    
    let videoFileName = "Video/" + dateString + ".mov"
    let thumbnailFileName = "Video/" + dateString + ".jpg"
    
    ProgressHUD.show("Sending video...")
    
    // save thumbnail
    
    backendless!.fileService.saveFile(thumbnailFileName, content: thumbnail as Data!, response: { (thumbnail) in
        
        print("THUMBNAIL UPLOADED")
        
        // save video
        backendless!.fileService.saveFile(videoFileName, content: video as Data!, response: { (file) in
            
            ProgressHUD.dismiss()
            result(file?.fileURL, thumbnail?.fileURL)
            
        }, error: { (fault) in
            ProgressHUD.showError("Error uploading video - \(fault!.detail)")
        })
        
    }) { (fault) in
        ProgressHUD.showError("Error uploading thumbnail \(fault!.detail!)")
    }
}


func downloadVideo(videoUrl: String, result: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
    
    let videoURL = NSURL(string: videoUrl)
    
    // access video file name
    let videoFileName = videoUrl.components(separatedBy: "/").last
    print("PRINTING VIDEO FILE NAME: \(String(describing: videoFileName))")
    // check if the file was downloaded before - if yes, save if locally
    if fileExistsAtPath(path: videoFileName!) {
        
        result(true, videoFileName!)
        
    } else {
        
        let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
        downloadQueue.async {
         //   let data = NSData(contentsOfFile: videoUrl)
              let data = NSData(contentsOf: videoURL as! URL)
            if data != nil {
                var docURL = getDocumentsURL()
                
                // now we can save video to our documentsURL
                docURL = docURL.appendingPathComponent(videoFileName!, isDirectory: false)
                // saving atomically so original won't be deleted until we get new one
                data!.write(to: docURL, atomically: true)
                
                DispatchQueue.main.async {
                    result(true, videoFileName!)
                }
            } else {
                ProgressHUD.showError("Video not found")
            }
        }
    }
    
}

func videoThumbnail(video: NSURL) -> UIImage {
    
    let asset = AVURLAsset(url: video as URL, options: nil)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    // take first second from video and return it as an image
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMake(Int64(0.5), 1000)
    var actualTime = kCMTimeZero
    
    var image: CGImage?
    
    do {
        // get our image
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
        
    } catch let error as NSError {
        print("PRINTING THUMBNAIL ERROR \(error.localizedDescription)")
    }
    
    let thumbnail = UIImage(cgImage: image!)
    
    return thumbnail
}

// Audio

func uploadAudio(audioPath: String, result: @escaping (_ audioLink: String?) -> Void) { // once we upload we get the link so we can save it in firebase
    
    let dateString = dateFormatter().string(from: Date())
    
    let audio = NSData(contentsOfFile: audioPath)
    let audioFileName = "Audio/" + dateString + ".m4a"
    
    ProgressHUD.show("Sending Audio...")
    
    // save audio
    backendless!.fileService.saveFile(audioFileName, content: audio as Data!, response: { (file) in
        
        ProgressHUD.dismiss()
        result(file!.fileURL)
        
    }) { (fault) in
        
        ProgressHUD.showError("Error uploading Audio: \(fault!.detail!)")
    }
}

func downloadAudio(audioUrl: String, result: @escaping (_ audioFileName: String) -> Void) {
    
    let audioURL = NSURL(string: audioUrl)
    let audioFileName = audioUrl.components(separatedBy: "/").last
    
    // check if it already exists so we don't have to download it again
    
    if fileExistsAtPath(path: audioFileName!) {
        result(audioFileName!)
    } else {
        // start downloading
        
        let dq = DispatchQueue(label: "audioDownload")
        
        dq.async {
            
            let data = NSData(contentsOf: audioURL! as URL)
            
            if data != nil {
                
                // saving it to our local directory so we don't have to download it again
                var docURL = getDocumentsURL()
                docURL = docURL.appendingPathComponent(audioFileName!, isDirectory: false)
                data!.write(to: docURL, atomically: true)
                
                DispatchQueue.main.async {
                    result(audioFileName!)
                }
            } else {
                print("No audio at link")
            }
        }
    }
}

// Helper

func fileInDocumentsDirectory(filename: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL.path
}

func getDocumentsURL() -> URL {
    
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    return documentURL!
}

func fileExistsAtPath(path: String) -> Bool {
    
    var doesExist = false
    
    let filePath = fileInDocumentsDirectory(filename: path)
    let fileManager = FileManager.default
    
    // check if file exists in file manager
    if fileManager.fileExists(atPath: filePath) {
        doesExist = true
    } else {
        doesExist = false
    }
    return doesExist
}









