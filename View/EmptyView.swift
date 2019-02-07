//
//  EmptyView.swift
//  cleanchat
//
//  Created by Javid Poornasir on 5/15/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import Foundation
import UIKit

func setupLabelForEmptyView(label: UILabel, message: String?, vc: UIViewController?, hide: Bool)  {
    if hide {
        label.isHidden = true
    } else {
        if let vc = vc, let message = message {
            label.isHidden = false
            vc.view.addSubview(label)
            label.frame.size = CGSize(width: 250, height: 250)
            label.center = vc.view.center
            label.backgroundColor = .clear
            label.textColor = .darkGray
            label.text = message
            label.textAlignment = .center
            label.numberOfLines = 0
        }
    }
}

