//
//  FriendCell.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/6/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation
import UIKit

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - ACTIONS
    
    func bindData(friend: BackendlessUser) {
        //circle
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.image = UIImage(named: "avatarPlaceholder")
        nameLabel.adjustsFontSizeToFitWidth = true  // in case name is too long; fixes font size
        nameLabel.minimumScaleFactor = 0.5      // prevents text from getting too small
        let withUserId = friend.objectId!
        let whereClause = "objectId = '\(withUserId)'"
        let dataQuery = DataQueryBuilder()
        dataQuery!.setWhereClause(whereClause)
        let dataStore = backendless!.persistenceService.of(BackendlessUser.ofClass())
        dataStore!.find(dataQuery, response: { (users) in
           print("PRINTING WITH B/E USER --- \(users)")
            let withUser = users!.first as! BackendlessUser
            print("PRINTING WITH B/E USER --- \(withUser)")
            if let avatarURL = withUser.getProperty("Avatar") {
                getAvatarFromURL(url: avatarURL as! String, result: { (image) in
                    self.avatarImageView.image = image
                })
            }
        }) { (fault) in
            ProgressHUD.showError("Couldn't get Avatar: \(fault!.detail!)")
        }
        // download user avatar
        nameLabel.text = friend.name as String
    }
    
    
    
    
}
