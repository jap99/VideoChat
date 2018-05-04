//
//  WelcomeVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/21/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class WelcomeVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var registerButtonOutlet: UIButton!
    @IBOutlet weak var loginWithFBButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        backendless!.userService.setStayLoggedIn(true)
        
        // check if user is available
        if backendless!.userService.currentUser != nil {
           
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, userInfo: ["userId" : backendless!.userService.currentUser.objectId])
            
            DispatchQueue.main.async {
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC-ID") as! UITabBarController
                vc.selectedIndex = 0
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.navigationController?.navigationBar.isHidden = false 
        self.hideKeyboardWhenTappedAround()
        
        // corner radius
        registerButtonOutlet.layer.cornerRadius = 5.0
        loginButtonOutlet.layer.cornerRadius = 5.0
        emailTextField.layer.cornerRadius = 5.0
        passwordTextField.layer.cornerRadius = 5.0
        loginWithFBButton.layer.cornerRadius = 5.0
        
        // border width
        emailTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderWidth = 0.5
        loginButtonOutlet.layer.borderWidth = 0.5
        registerButtonOutlet.layer.borderWidth = 0.5
        
        // border color
        emailTextField.layer.borderColor = lightBlue.cgColor
        passwordTextField.layer.borderColor = lightBlue.cgColor
        loginButtonOutlet.layer.borderColor = lightBlue.cgColor
        registerButtonOutlet.layer.borderColor = lightBlue.cgColor
        
        // shadow color
        emailTextField.layer.shadowColor = lightBlue.cgColor
        passwordTextField.layer.shadowColor = lightBlue.cgColor
        loginButtonOutlet.layer.shadowColor = lightBlue.cgColor
        registerButtonOutlet.layer.shadowColor = lightBlue.cgColor
        
        // shadow radius
        emailTextField.layer.shadowRadius = 6.0
        passwordTextField.layer.shadowRadius = 6.0
        loginButtonOutlet.layer.shadowRadius = 4.0
        registerButtonOutlet.layer.shadowRadius = 4.0
        
        // shadow opacity
        emailTextField.layer.shadowOpacity = 4.0
        passwordTextField.layer.shadowOpacity = 4.0
        loginButtonOutlet.layer.shadowOpacity = 4.0
        registerButtonOutlet.layer.shadowOpacity = 4.0
        
        // background color
//        loginButtonOutlet.backgroundColor = lead
//        registerButtonOutlet.backgroundColor = lead
//
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey: pinkColor,kCTFontAttributeName as NSAttributedStringKey :UIFont(name: "Avenir", size: 13)!])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey: pinkColor,kCTFontAttributeName as NSAttributedStringKey :UIFont(name: "Avenir", size: 13)!])
        
        
    }

    @IBAction func fbLoginButtonPressed(_ sender: Any) {
        
        // since we're using custom facebook button and not the standard one, we use facebook login manager instead of facebook login button
        
        let fbLoginManager = FBSDKLoginManager()

        // what we're asking of the user
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            
            if error != nil {
                print("Error logging in with Facebook: \(error!.localizedDescription)")
                return
            }
            
            // else log user in with backendless
            
            if let token = result?.token {
                print("RESULT'S TOKEN PRINTED - \(token)")
                
                let userId: String = token.userID
                let tokenStringg: String = token.tokenString
                let expirationDate: Date = token.expirationDate
                let fieldsMapping = ["id": "facebookId", "name": "name", "email": "email", "birthday": "birthday", "first_name": "fb_first_name", "last_name": "fb_last_name", "gender": "gender"] // the left side is how it's shown in facebook and the right side is how it will show in the b.e. table
                
                // access token - pass our access token in from facebook; once we're logged in, the result from our callback will have our access token
                // fields mapping - b.e. needs to know which info from facebook it needs to map to put the user table in our b.e.
                backendless!.userService.login(withFacebookSDK: userId, tokenString: tokenStringg, expirationDate: expirationDate, fieldsMapping: fieldsMapping, response: { (user) in
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, userInfo: ["userId" : user!.objectId])
                    
                    // go to app after fb user's registered
                    
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC-ID") as! UITabBarController
                    vc.selectedIndex = 0
                    self.present(vc, animated: true, completion: nil)
                    
                    self.updateFacebookUser()
                    
                    // get avatar from facebook and update b.e.
                }, error: { (fault) in
                    print("ERROR REGISTERING USER WITH FB ACCOUNT: \(fault!.detail!)")
                })
            }
        }
    }
    
    func updateFacebookUser() {
        
        // make graph request for avatar
        
        // get email onlly
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "email"]).start { (connection, result, error) in
            
            if error != nil {
                print("ERROR FACEBOOK GRAPH REQUEST: \(error!.localizedDescription)")
                return
            }
            
            if let facebookId = (result as! NSDictionary)["id"] as? String {
                
                // use the user's id to get the user's avatar
                let avatarUrl = "http://graph.facebook.com/\(facebookId)/picture?type=normal"
                
                updateBackendlessUser(avatarUrl: avatarUrl)
                
            } else {
                print("FACEBOOK REQUEST ERROR, no facebook ID")
            }
        }
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
            
            registerUserDeviceID(user: user!)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, userInfo: ["userId" : user!.objectId])
             
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
            self.view.endEditing(false)
            
            // go to app
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC-ID") as! UITabBarController
            vc.selectedIndex = 0
            self.present(vc, animated: true, completion: nil)
            
            
        }) { (fault) in
            
            ProgressHUD.showError("Could not login: \(fault!.detail!)")
        }
    }
    
    
    
    

}
