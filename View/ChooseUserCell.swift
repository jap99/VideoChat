//
//  ChooseUserCell.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/22/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import UIKit

class ChooseUserCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    // MARK: - INIT
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    // MARK: - ACTIONS
    
    func bindData(friend: BackendlessUser) {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.image = UIImage(named: "avatarPlaceholder")
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        // download user avatar
        let withUserId = friend.objectId!
        let whereClause = "objectId = '\(withUserId)'"
      //  let dataQuery = BackendlessDataQuery()
        let dataQuery = DataQueryBuilder()
        dataQuery!.setWhereClause(whereClause)
        // start accessing our user
        let dataStore = backendless!.persistenceService.of(BackendlessUser.ofClass())
        dataStore!.find(dataQuery, response: { (users) in
        //    let withUser = users!.data.first as! BackendlessUser
                let withUser = users!.first as! BackendlessUser
            if let avatarURL = withUser.getProperty("Avatar")  {
                getAvatarFromURL(url: avatarURL as! String, result: { (image) in
                    self.avatarImageView.image = image
                })
            }
        }) { (fault) in
            ProgressHUD.showError("Couldn't get Avatar for user: \(fault!.detail!)")
        }
        nameLabel.text = friend.name as String
    }
    
    

}
