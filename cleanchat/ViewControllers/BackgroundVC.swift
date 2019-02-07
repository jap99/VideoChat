//
//  BackgroundVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/24/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit

class BackgroundVC: UIViewController {
    
    let userDefaults = UserDefaults.standard
    var firstLoad: Bool?
    
    @IBOutlet weak var redO: UISlider!
    @IBOutlet weak var greenO: UISlider!
    @IBOutlet weak var blueO: UISlider!
    @IBOutlet weak var colorCubeView: UIView!
    
    
    // MARK: - INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorCubeView.layer.borderWidth = 1
        colorCubeView.layer.borderColor = UIColor.lightGray.cgColor
        colorCubeView.layer.cornerRadius = 3.0
        // laodUserDefaults
    }
    
    
    // MARK: IB_ACTIONS
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        saveUserDefaults()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sliderValueChanged(_ sender: AnyObject) {
        updateUI()
    }
    
    
    // MARK: - ACTIONS
    
    func updateUI() {
        colorCubeView.backgroundColor = UIColor(red: CGFloat(redO.value), green: CGFloat(greenO.value), blue: CGFloat(blueO.value), alpha: 1.0)
    }
    
    func saveUserDefaults() {
        userDefaults.set(redO.value, forKey: kRED)
        userDefaults.set(greenO.value, forKey: kGREEN)
        userDefaults.set(blueO.value, forKey: kBLUE)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() { // gets our status from user defaults and puts bg color in correct position
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(1.0, forKey: kRED)
            userDefaults.set(1.0, forKey: kGREEN)
            userDefaults.set(1.0, forKey: kBLUE)
            userDefaults.synchronize()
        }
        redO.setValue(userDefaults.float(forKey: kRED), animated: true)
        blueO.setValue(userDefaults.float(forKey: kBLUE), animated: true)
        greenO.setValue(userDefaults.float(forKey: kGREEN), animated: true)
        updateUI()
    }
    
    
    
}
