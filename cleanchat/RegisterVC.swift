//
//  RegisterVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/21/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import UIKit
import MobileCoreServices
import Foundation

class RegisterVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var newUser: BackendlessUser?
    var avatarImage: UIImage?
    var imagePicker: UIImagePickerController?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButtonOutlet: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImage_HeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - START


    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        setupGestureRecognizer()
        self.profileImage_HeightConstraint.constant = 1
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        
        self.navigationController?.navigationBar.tintColor = lead
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.darkGray
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.darkGray
        
        // corner radius
       emailTextField.layer.cornerRadius = 3.0
       passwordTextField.layer.cornerRadius = 3.0
       usernameTextField.layer.cornerRadius = 3.0
       registerButtonOutlet.layer.cornerRadius = 3.0
        
        // border color
        emailTextField.layer.borderColor = UIColor.darkText.cgColor
        passwordTextField.layer.borderColor = UIColor.darkText.cgColor
        usernameTextField.layer.borderColor = UIColor.darkText.cgColor
        registerButtonOutlet.layer.borderColor = UIColor.darkText.cgColor
        
        // border width
        emailTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderWidth = 0.5
        usernameTextField.layer.borderWidth = 0.5
        registerButtonOutlet.layer.borderWidth = 0.5
        
        // background color
        registerButtonOutlet.backgroundColor = .white
        
        // text color
        registerButtonOutlet.setTitleColor(darkBlue, for: .normal)
        
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

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        emailTextField.textColor = darkBlue
        passwordTextField.textColor = darkBlue
        usernameTextField.textColor = darkBlue
    }
    
    // MARK: - SETUP
    
    func setup1() {
        
    }
    
    func setup2() {
        
    }
    
    func setupGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(RegisterVC.tapGesture))
        self.profileImageView.addGestureRecognizer(gesture)
    }
    
    @objc func tapGesture() {
        presentCameraOptions()
    }
    
    
    // MARK: - ACTIONS
    
    func presentCameraOptions() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = Camera(delegate_: self)
        let takePhoto =  UIAlertAction(title: "Take Photo", style: .default) { (alert) in
            self.profileImageView.image = nil
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
            //            else {
            //
            //                // if no image selected, provide avatar image
            //                if let firstCharacter = self.usernameTextField.text?.lowercased().first {
            //
            //                    let avatarImage = UIImage(named: "icons8-circled_\(firstCharacter)")
            //                    self.avatarImage = avatarImage
            //                    uploadAvatar(image: self.avatarImage!, result: { (imageLink) in
            //
            //                        let properties = ["Avatar" : imageLink!]
            //
            //                        backendless!.userService.currentUser.updateProperties(properties)
            //
            //                        backendless!.userService.update(backendless!.userService.currentUser, response: { (updatedUser) in
            //                            print("Updated avatar image with letter icon")
            //                        }, error: { (fault) in
            //                            ProgressHUD.showError("Couldn't update user: \(fault!.detail!)")
            //                        })
            //                    })
            //                }
            //            }
            
            // go to app
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC-ID") as! UITabBarController
            vc.selectedIndex = 0
            self.present(vc, animated: true, completion: nil)
        }) { (fault) in
            ProgressHUD.showError("Could not login: \(fault!.detail!)")
        }
    }
    
    
    // MARK: - IB_ACTIONS
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        presentCameraOptions()
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if emailTextField.text != "" && usernameTextField.text != "" && passwordTextField.text != "" {
            ProgressHUD.show("Registering...", interaction: false)
            register(email: emailTextField.text!, username: usernameTextField.text!, password: passwordTextField.text!, avatarImage: avatarImage)
        } else { 
            ProgressHUD.showError("Email and Password Required")
        }
    }
    
    
    // MARK: - IMAGE_PICKER_CONTROLLER_DELEGATE
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.profileImage_HeightConstraint.constant = 120
        self.profileImageView.image = nil
        print(info)
//        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
//            self.profileImageView.contentMode = .scaleAspectFit
//            self.avatarImage = img
//            self.profileImageView.image = img
//            self.view.setNeedsLayout()
//        }
        picker.dismiss(animated: true, completion: nil)
    }
    

    
    
    
}
