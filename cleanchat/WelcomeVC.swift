//
//  WelcomeVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/21/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var registerButtonOutlet: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        backendless!.userService.setStayLoggedIn(true)
        
        // check if user is available
        if backendless!.userService.currentUser != nil {
           
//            DispatchQueue.main.async {
//                
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecentVC") as! UITabBarController
//                vc.selectedIndex = 0
//                self.present(vc, animated: true, completion: nil)
//            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            ProgressHUD.show("Logging in...", interaction: false)
            loginUser(email: emailTextField.text!, password: passwordTextField.text!)
        } else {
            
            ProgressHUD.showError("Email and Password Required")
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
    }
    
    
    
    func loginUser(email: String, password: String) {
        
        ProgressHUD.dismiss()
        backendless!.userService.login(email, password: password, response: { (user) in
            
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
            self.view.endEditing(false)
            
            // go to app
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecentVC") as! UITabBarController
            vc.selectedIndex = 0
            self.present(vc, animated: true, completion: nil)
            
            
        }) { (fault) in
            
            ProgressHUD.showError("Could not login: \(fault!.detail)")
        }
    }
    
    
    
    

}
