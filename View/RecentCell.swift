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
    
    
    // MARK: - INIT
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.layer.cornerRadius = 4.0
//        self.clipsToBounds = true
//        self.contentView.layer.borderWidth = 0.5
//        self.layer.borderColor = UIColor.lightGray.cgColor
       // self.backgroundColor = .white
    }
    
    
    // MARK: - ACTIONS
    
    func bindData(recent: NSDictionary) {
        //circle
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
       // avatarImageView.layer.masksToBounds = true
        
       // avatarImageView.image = UIImage(named: "ic_account_circle_white")
        avatarImageView.clipsToBounds = true
        //avatarImageView.backgroundColor = lead
        
//        avatarImageView.layer.borderColor = darkBlue.cgColor
//        avatarImageView.layer.borderWidth = 2.0
//       // avatarImageView.layer.shadowOffset = CGSize(width: 5, height: 5)
//        avatarImageView.layer.shadowColor = UIColor.darkText.cgColor
//        avatarImageView.layer.shadowRadius = 5.0
//        avatarImageView.layer.shadowOpacity = 5.0
//
        // in case name is too long; fixes font size
        nameLabel.adjustsFontSizeToFitWidth = true
        
        // prevents text from getting too small
        nameLabel.minimumScaleFactor = 0.5
        
        // check if group or private chat
        if (recent[kTYPE] as? String)! == kPRIVATE {
            let withUserId = (recent[kWITHUSERUSERID] as! String)
            let whereClause = "objectId = '\(withUserId)'"
            let dataQuery = DataQueryBuilder()
            dataQuery!.setWhereClause(whereClause)
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
        } // specify name label, counter and last message
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
        if seconds < 120 {
            elapsed = "Just Now"
        } else {
            // return date of the message
            let currentDateFormatter = dateFormatter()
            currentDateFormatter.dateFormat = "MM/dd"
            elapsed = "\(currentDateFormatter.string(from: date))"
        }
        return elapsed!
    }
    
    
    
    

}
