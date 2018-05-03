//
//  AppDelegate.swift
//  cleanchat
//
//  Created by Javid Poornasir on 7/21/17.
//  Copyright © 2017 Javid Poornasir. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import NotificationCenter
import FBSDKCoreKit
//import UserNotificationsUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, SINClientDelegate, SINCallClientDelegate, SINManagedPushDelegate {

    var _client: SINClient!
    var push: SINManagedPush!
    
    var window: UIWindow?
    
    // setup for our location
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?
    
    let APP_ID = "48E0C0BD-4D5D-7547-FFD1-C6819D10B800"
    let API_KEY = "AA407415-008C-0F4C-FF10-C8E3966D9600" // aka API KEY
    let VERSION_NUM = "v1"
    
    let sinchKey = "6515f8d8-b374-49f1-b9f3-02d201f69ec6"
    let sinchSecret = "tctoTFJAMEu0aq/D67pH5A=="

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Sinch Push
        self.push = Sinch.managedPush(with: .development)
        self.push.delegate = self
        self.push.setDesiredPushTypeAutomatically()
        
        func onUserDidLogin(userID: String) {
            
            // we'll have a notif center observer
            self.push.registerUserNotificationSettings()
            
            // init sinch
            self.initSinchWithUserID(userId: userID)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, queue: nil) { (note) in
            
            let userID = note.userInfo!["userId"] as! String
            UserDefaults.standard.set(userID, forKey: "userId") // save userID to userdefaults
            UserDefaults.standard.synchronize()
            
            onUserDidLogin(userID: userID)
            
        }
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true // signals to FB that there should be local persistence as well for when we're offline
        backendless!.initApp(APP_ID, apiKey: API_KEY)

        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback on earlier versions
            
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
            
//            let types: UIUserNotificationType = [.alert, .badge, .sound]
//            let settings = UIUserNotificationSettings
//            application.registerUserNotificationSettings(settings)
        }
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if let launchOptions = launchOptions {
            if let notificationsDict = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? [NSObject: AnyObject] {
                self.application(application, didReceiveRemoteNotification: notificationsDict)
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
       
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        locationManagerStop()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        locationManagerStart()
        FBSDKAppEvents.activateApp()
        
        application.applicationIconBadgeNumber = 0 
    }

    func applicationWillTerminate(_ application: UIApplication) {
       
    }
    
    // MARK: Location Manager
    
    func locationManagerStart() {
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        
        locationManager!.startUpdatingLocation()
    }
    
    func locationManagerStop() {
        
        locationManager!.stopUpdatingLocation()
    }


    // MARK: Location ManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("FAILED TO GET LOCATION")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .restricted:
            // restricted by ie. parental controls so can't enable location services
            break
        case .denied:
            locationManager = nil
            print("DENIED LOCATION")
            // can grant access from Settings.app
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        coordinates = locations.last!.coordinate
    }
    
    
    // MARK: Facebook login
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let result: Bool = false
        if #available(iOS 9.0, *) {
            let resultt = FBSDKApplicationDelegate.sharedInstance().application(app, open: url,
                                                                               sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
                                                                               annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            return resultt
        
        } else {
            // Fallback on earlier versions
             return result
            
        }
        
    }
    
    
    // MARK: Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        self.push.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken) // SinchRTC
        
        // register device with backendless here
        backendless!.messagingService.registerDevice(deviceToken, response: { (success) in
            print("REGISTERED FOR REMOTE NOTIFICATIONS")
        }) { (error) in
            print("ERROR REGISTERING FOR REMOTE NOTIFICATIONS - APP DELEGATE - ERROR: \(error!.detail!)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        self.push.application(application, didReceiveRemoteNotification: userInfo) // SinchRTC
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("DID FAIL TO REGISTER FOR REMOTE NOTIFICATIONS - ERROR: \(error)")
    }
    
    // MARK: Sinch init
    
    func initSinchWithUserID(userId: String) {
        
        if _client == nil {
            
            _client = Sinch.client(withApplicationKey: sinchKey, applicationSecret: sinchSecret, environmentHost: "clientapi.sinch.com", userId: userId)
            
            _client.delegate = self
            _client.call().delegate = self
            _client.setSupportCalling(true)
            _client.enableManagedPushNotifications()
            _client.start()
            _client.startListeningOnActiveConnection()
        }
        
    }
    
    
    func handleRemoteNotifications(userInfo: NSDictionary) {
        
        if _client != nil {
            
            let userId = UserDefaults.standard.object(forKey: "userId")
            
            if userId != nil {
                
                self.initSinchWithUserID(userId: userId as String) // starts our Sinch client
            }
        }
        
        self._client.relayRemotePushNotification(userInfo as! [AnyHashable: Any])
    }
    
    
    // MARK: SINManagedPushDelegate
    
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        self.handleRemoteNotifications(userInfo: payload as NSDictionary)
    }
    
    // MARK: SINCallClientDelegate
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("HAVE A CALL")
        // access our call screen
        var top = self.window?.rootViewController
        
        while (top?.presentedViewController != nil) {
            top = top?.presentedViewController
        }
        
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallVC-ID") as! CallVC
        callVC._call = call
        top?.present(callVC, animated: true, completion: nil)
    }
    
    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        let notif = SINLocalNotification()
        notif.alertAction = "Answer"
        notif.alertBody = "Incoming Call"
        
        return notif
    }
    
    // MARK: SINClientDelegate
    
    func clientDidStart(_ client: SINClient!) {
        print("SINCH CLIENT STARTED")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("SINCH CLIENT FAILED")
    }
    
    func client(_ client: SINClient!, logMessage message: String!, area: String!, severity: SINLogSeverity, timestamp: Date!) {
        if severity == .critical {
            print("MESSAGE: \(message)")
        }
    }
    
    
}

