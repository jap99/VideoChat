//
//  Camera.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/21/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import Foundation
import MobileCoreServices
import UIKit 


final class Camera {      // Camera, photo library, access & get the image back
    
    var delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
    
    // MARK: - INIT
    
    init(delegate_: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        delegate = delegate_    // sets our delegate for the camera
    }
    
    
    // MARK: - ACTIONS
    
    // PHOTO LIBRARY
    
    func presentPhotoLibrary(target: UIViewController, canEdit: Bool) {
        // target's the vc wanting to present camera
        // canEdit is whether user can edit picture after it's' chosen or taken
        //check if photo library is available on our device else return w/o crashing
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
            return
        }
        let imageType = kUTTypeImage as String //kUTTypeImage is an apple type which only displays the images in user's library; won't show the videos
        let imagePicker = UIImagePickerController()
        // checking again if we can access the photo library
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            if let availablePhotoTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                // checking if album contains any of the type that we want; images in this case
                if (availablePhotoTypes as NSArray).contains(imageType) {
                    /* Set up defaults */
                    imagePicker.mediaTypes = [imageType] //setting the type
                    imagePicker.allowsEditing = canEdit
                }
            }
            // checking again if we can access the saved photos album
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.sourceType = .savedPhotosAlbum
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                // checking if album contains any of the type that we want; images in this case
                if (availableTypes as NSArray).contains(imageType) {
                    imagePicker.mediaTypes = [imageType]
                }
            }
        } else {
            return
        }
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil) // presents the imagepicker to the user
        return
    }
    
    // MULTI CAMERA
    
    func presentMultiCamera(target: UIViewController,  canEdit: Bool) {
        // check if device has a camera
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            return
        }
        // multi camera can access two types - image and movie
        let type1 = kUTTypeImage as String
        let type2 = kUTTypeMovie as String
        let imagePicker = UIImagePickerController()
        // checking if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if (availableTypes as NSArray).contains(type1) {
                    // passing in image and video so we can have both at same time
                    imagePicker.mediaTypes = [type1, type2]
                    imagePicker.sourceType = UIImagePickerController.SourceType.camera
                }
            }
            // set rear camera to default if available
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.rear
           
            } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.front
            }
        } else {
            //show alert, no camera available
            return
        }
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil) // presents the imagepicker to the user
    }
    
    func presentPhotoCamera(target: UIViewController,  canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            return
        }
        let type1 = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if (availableTypes as NSArray).contains(type1) {
                    imagePicker.mediaTypes = [type1]
                    imagePicker.sourceType = UIImagePickerController.SourceType.camera
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.rear
            }
            else if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.front
            }
        } else {
            //show alert, no camera available
            return
        }
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil) // presents the imagepicker to the user
    }
    
    // VIDEO CAMERA
    
    func presentVideoCamera(target: UIViewController,  canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            return
        }
        let type1 = kUTTypeMovie as String
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if (availableTypes as NSArray).contains(type1) {
                    imagePicker.mediaTypes = [type1]
                    imagePicker.sourceType = UIImagePickerController.SourceType.camera
                    imagePicker.videoMaximumDuration = kMAXDURATION
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.rear
            } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.front
            }
        } else {
            //show alert, no camera available
            return
        }
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil) // presents the imagepicker to the user
    }
    
    // VIDEO LIBRARY
    
    func presentVideoLibrary(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
            return
        }
        let type = kUTTypeMovie as String
        let imagePicker = UIImagePickerController()
        imagePicker.videoMaximumDuration = kMAXDURATION
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                if (availableTypes as NSArray).contains(type) {
                    /* Set up defaults */
                    imagePicker.mediaTypes = [type]
                    imagePicker.allowsEditing = canEdit
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.sourceType = .savedPhotosAlbum
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                if (availableTypes as NSArray).contains(type) {
                    imagePicker.mediaTypes = [type]
                }
            }
        } else {
            return
        }
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil) // presents the imagepicker to the user
        return
    }
    
    
    
    
}
