//
//  VideoMessage.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/13/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

class VideoMessage: JSQMediaItem {
    
    // will create video class and return video item
    
    var image: UIImage?
    var videoImageView: UIImageView?
    var status: Int?
    var fileURL: NSURL?
    
    init(withFileURL: NSURL, maskOutgoing: Bool) {
        
        super.init(maskAsOutgoing: maskOutgoing)
        
        fileURL = withFileURL
        
        // get video image view
        videoImageView = nil
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented")
    }
    
    override func mediaView() -> UIView! {
        
        if let st = status {
            
            if st == 1 {
                
                print("DOWNLOADING")
                return nil
            }
            
            if st == 2 && (self.videoImageView == nil) {
                
                // create video message
                print("SUCCESS")
                
                // getting default size
                let size = self.mediaViewDisplaySize()
                
                let outgoing = self.appliesMediaViewMaskAsOutgoing
                
                // white play button
                let icon = UIImage.jsq_defaultPlay().jsq_imageMasked(with: .white)
                
                let iconView = UIImageView(image: icon)
                
                iconView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                
                iconView.contentMode = UIView.ContentMode.center
                let imageView = UIImageView(image: self.image!)
                imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                
                // fill view with our image
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.addSubview(iconView)
                
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
                
                self.videoImageView = imageView
            }
        }
        return self.videoImageView
    }
    
    
    
    
    
    
    
    
    
}





