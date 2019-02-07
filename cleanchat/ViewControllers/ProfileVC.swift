//
//  ProfileVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 5/2/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    var user = BackendlessUser()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    // MARK: - INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
 
    
    // MARK: - ACTIONS
    
    func updateUI() {
        let placeholderImage = UIImage(named: "avatarPlaceholder")
        self.imageView.image = placeholderImage!
        nameLabel.text = user.name as String
        // DL profile pic if exists
        if let avatarURL = user.getProperty("Avatar") {
            getAvatarFromURL(url: avatarURL as! String) { (image) in
                self.imageView.image = image!
            }
        }
    }
    
    
    // MARK: - IB_ACTIONS
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
}
