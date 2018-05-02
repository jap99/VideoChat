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
    
    
    func bindData(friend: BackendlessUser) {
        
        //circle
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.masksToBounds = true
        
        avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        // in case name is too long; fixes font size
        nameLabel.adjustsFontSizeToFitWidth = true 
        
        // prevents text from getting too small
        nameLabel.minimumScaleFactor = 0.5
        
        let withUserId = friend.objectId!
        let whereClause = "objectId = '\(withUserId)'"
        let dataQuery = DataQueryBuilder()
        dataQuery!.setWhereClause(whereClause)
        
        let dataStore = backendless!.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore!.find(dataQuery, response: { (users) in
           // print(users)
            let withUser = users!.first as! BackendlessUser
            //print(withUser)
            
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
