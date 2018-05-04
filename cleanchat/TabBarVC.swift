//
//  TabBarVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 5/4/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {
    
    let arrayOfImageNameForSelectedState = ["ic_inbox_white_48pt", "Group", "Contact", "settings"]
    let arrayOfImageNameForUnselectedState = ["ic_inbox_white_48pt", "Group", "Contact", "settings"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.isTranslucent = false
        updateTabBarColors()
    }
    
    
    func updateTabBarColors() {
        
        UITabBarItem.appearance().setTitleTextAttributes([kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.lightGray], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.darkText], for: .selected)
        self.tabBar.tintColor = lightBlue
        self.tabBar.layer.shadowOpacity = 5.0
        self.tabBar.layer.shadowColor = lightBlue.cgColor//pinkBorder//UIColor.black.cgColor
        self.tabBar.layer.shadowRadius = 4.0
        
        self.tabBar.barTintColor = UIColor.darkText
        
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = UIColor.lightGray
        } else { }
        
        if let count = self.tabBar.items?.count {
            for i in 0...(count-1) {
                let imageNameForSelectedState   = arrayOfImageNameForSelectedState[i]
                let imageNameForUnselectedState = arrayOfImageNameForUnselectedState[i]
                
                self.tabBar.items?[i].selectedImage = UIImage(named: imageNameForSelectedState)
                self.tabBar.items?[i].image = UIImage(named: imageNameForUnselectedState)
            }
        }
    }
    
    
}
