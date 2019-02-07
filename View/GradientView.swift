//
//  GradientView.swift
//  cleanchat
//
//  Created by Javid Poornasir on 5/4/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//
import UIKit

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var cOne: UIColor = lead {
        didSet {
            self.setNeedsLayout() // calls layoutSubviews
        }
    }
    
    @IBInspectable var cTwo: UIColor = #colorLiteral(red: 1, green: 0.3840791049, blue: 0.8340719722, alpha: 1) {
        didSet {
            self.setNeedsLayout() // calls layoutSubviews
        }
    }
    
    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        // needs colors, starting and end point, and how large it will be
        gradientLayer.colors = [cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor, cOne.cgColor, cTwo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)     // place it at the first layer aka at: 0
    }
    
}
