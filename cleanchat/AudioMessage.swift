//
//  AudioMessage.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/17/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation

class AudioMessage: JSQMediaItem {
    
    var imageView: UIImageView?
    var status: Int?
    var fileURL: NSURL?
    
    init(withFileURL: NSURL, maskOutgoing: Bool) {
        
        super.init(maskAsOutgoing: maskOutgoing)
        
        fileURL = withFileURL
        imageView = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented")
    }
    
    override func mediaView() -> UIView! {
        
        if let st = status {
            
            if st == 1 {
                return nil
            }
            
            if st == 2 && (self.imageView == nil) {
                
                let size = self.mediaViewDisplaySize()
                let outgoing = self.appliesMediaViewMaskAsOutgoing
                
                let colorBg = outgoing ? UIColor.jsq_messageBubbleBlue() : UIColor.jsq_messageBubbleLightGray()
                
                let colorContent = outgoing ? UIColor.white : UIColor.gray
                
                let icon = UIImage.jsq_defaultPlay().jsq_imageMasked(with: colorContent)
                
                let iconView = UIImageView(image: icon)
                let yPos = (size().height - icon!.size.height) / 2
                let xPos = outgoing ? yPos : yPos + 6
                
                iconView.frame = CGRect(x: xPos, y: yPos, width: icon!.size.width, height: icon!.size.height)
                let frame = outgoing ? CGRect(x: 45, y: 10, width: 60, height: 20) : CGRect(x: 51, y: 10, width: 60, height: 20)
                
                let label = UILabel(frame: frame)
                label.textAlignment = .right
                label.textColor = colorContent
                label.text = "Audio"
                
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size().width, height: size().height))
                
                imageView.backgroundColor = colorBg
                imageView.clipsToBounds = true
                imageView.addSubview(iconView)
                imageView.addSubview(label)
                
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
                self.imageView = imageView
            }
        }
        return self.imageView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 120, height: 40)
    }
    
    
    
    
    
    
    
    
    
    
    
}
