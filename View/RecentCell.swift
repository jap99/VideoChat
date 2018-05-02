//
//  RecentCell.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/22/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import UIKit

class RecentCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
 
    }
    
    
    func bindData(recent: NSDictionary) {
        
        //circle
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.masksToBounds = true
        
        avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        // in case name is too long; fixes font size
        nameLabel.adjustsFontSizeToFitWidth = true
        
        // prevents text from getting too small
        nameLabel.minimumScaleFactor = 0.5
        
        // check if group or private chat
        if (recent[kTYPE] as? String)! == kPRIVATE {
            
            let withUserId = (recent[kWITHUSERUSERID] as! String)
            let whereClause = "objectId = '\(withUserId)'"
            let dataQuery = DataQueryBuilder()
            dataQuery?.setWhereClause(whereClause)
            
            let dataStore = backendless!.persistenceService.of(BackendlessUser.ofClass())
            dataStore!.find(dataQuery, response: { (users) in
                
                let withUser = users?.first as! BackendlessUser
                
                if let avatarUrl = withUser.getProperty("Avatar") {
                    
                    getAvatarFromURL(url: avatarUrl as! String, result: { (image) in
                        
                        self.avatarImageView.image = image
                    })
                }
            }, error: { (fault) in
                ProgressHUD.showError("Couldn't Download avatar: \(fault!.detail!)")
                
            })
        }
        // specify name label, counter and last message
        nameLabel.text = recent[kWITHUSERUSERNAME] as? String
        lastMessageLabel.text = decryptText(chatRoomID: (recent[kCHATROOMID] as? String)!, text: (recent[kLASTMESSAGE] as? String)!)
        counterLabel.text = ""
        
        if (recent[kCOUNTER] as? Int)! != 0 {
            counterLabel.text = "\(recent[kCOUNTER]!) New"
        }
        
        let date = dateFormatter().date(from: recent[kDATE] as! String)
        dateLabel.text = timeElapsed(date: date!)
    }
    
    func timeElapsed(date: Date) -> String {
        
        let seconds = NSDate().timeIntervalSince(date)
        let elapsed: String?
        
        // depends on how many seconds have passed
        if seconds < 60 {
            elapsed = "Just Now"
        } else {
            // return date of the message
            let currentDateFormatter = dateFormatter()
            currentDateFormatter.dateFormat = "dd/MM"
            
            elapsed = "\(currentDateFormatter.string(from: date))"
        }
        
        return elapsed!
    }
    
    
    
    

}
