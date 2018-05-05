//
//  RegisterVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/21/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import UIKit
import MobileCoreServices

class RegisterVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButtonOutlet: UIButton!
    
    var newUser: BackendlessUser?
    var avatarImage: UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
         UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = darkBlue
        
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // corner radius
       emailTextField.layer.cornerRadius = 4.0
       passwordTextField.layer.cornerRadius = 4.0
       usernameTextField.layer.cornerRadius = 4.0
       registerButtonOutlet.layer.cornerRadius = 4.0
        
        // border color
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        usernameTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        // border width
        emailTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderWidth = 0.5
        usernameTextField.layer.borderWidth = 0.5
        
        //shadow color
//        emailTextField.layer.shadowColor = .cgColor
//        passwordTextField.layer.shadowColor = lightBlue.cgColor
//        usernameTextField.layer.shadowColor = lightBlue.cgColor
//        registerButtonOutlet.layer.shadowColor = lightBlue.cgColor
        
//        // shadow radius
//        emailTextField.layer.shadowRadius = 6.0
//        passwordTextField.layer.shadowRadius = 6.0
//        usernameTextField.layer.shadowRadius = 6.0
//        registerButtonOutlet.layer.shadowRadius = 6.0
//
//        // shadow opacity
//        emailTextField.layer.shadowOpacity = 4.0
//        passwordTextField.layer.shadowOpacity = 4.0
//        usernameTextField.layer.shadowOpacity = 4.0
//        registerButtonOutlet.layer.shadowOpacity = 4.0
//
//        // placeholder color
//        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey: pinkColor,kCTFontAttributeName as NSAttributedStringKey :UIFont(name: "Avenir", size: 13)!])
//        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey: pinkColor,kCTFontAttributeName as NSAttributedStringKey :UIFont(name: "Avenir", size: 13)!])
//        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey: pinkColor,kCTFontAttributeName as NSAttributedStringKey :UIFont(name: "Avenir", size: 13)!])
        self.navigationController?.isNavigationBarHidden = false
        newUser = BackendlessUser() 
        
        self.hideKeyboardWhenTappedAround()
        
        
    }

    
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = Camera(delegate_: self)
        
        let takePhoto =  UIAlertAction(title: "Take Photo", style: .default) { (alert) in
            camera.presentPhotoCamera(target: self, canEdit: true)
        }
        
        let sharePhoto =  UIAlertAction(title: "Photo Library", style: .default) { (alert) in
            camera.presentPhotoLibrary(target: self, canEdit: true)
        }
        
        let cancelPhoto =  UIAlertAction(title: "Cancel", style: .default) { (alert) in }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelPhoto)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        if emailTextField.text != "" && usernameTextField.text != "" && passwordTextField.text != "" {
            
            ProgressHUD.show("Registering...", interaction: false)
            register(email: emailTextField.text!, username: usernameTextField.text!, password: passwordTextField.text!, avatarImage: avatarImage)
        
        } else { 
            ProgressHUD.showError("Email and Password Required")
        }
    }
    
    
    
    func register(email: String, username: String, password: String, avatarImage: UIImage?) {
        
        newUser!.setProperty("Avatar", object: "")
        
        newUser!.email = email as NSString
        newUser!.password = password as NSString
        newUser!.name = username as NSString
        
        ProgressHUD.dismiss()
        
        backendless!.userService.register(newUser, response: { (registeredUser) in
            
            // log user in
            self.loginUser(email: email, password: password)
            
        }) { (fault) in
            
            ProgressHUD.showError("Couldn't register: \(fault!.detail!)")
        }
        
    }


    
    func loginUser(email: String, password: String) {
        
        backendless!.userService.login(email, password: password, response: { (user) in
            
            registerUserDeviceID(user: user!)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, userInfo: ["userId" : user!.objectId])
            
            if self.avatarImage != nil {
                
                uploadAvatar(image: self.avatarImage!, result: { (imageLink) in
                    
                    let properties = ["Avatar" : imageLink!]
                    
                    backendless!.userService.currentUser.updateProperties(properties)
                    
                    // now save it so it's not only a local update
                    backendless!.userService.update(backendless!.userService.currentUser, response: { (updatedUser) in
                        
                        print("Updated avatar image link")
                        
                    }, error: { (fault) in
                        
                        ProgressHUD.showError("Couldn't update user: \(fault!.detail!)")
                    })
                })
            }
            
            // go to app
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC-ID") as! UITabBarController
            vc.selectedIndex = 0
            self.present(vc, animated: true, completion: nil)
            
        }) { (fault) in
            
            ProgressHUD.showError("Could not login: \(fault!.detail!)")
        }
    }
    
    
    // MARK: - UIImagePickerController Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.avatarImage = (info[UIImagePickerControllerEditedImage] as! UIImage)
        
        picker.dismiss(animated: true, completion: nil)
    }
}
