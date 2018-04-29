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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
    // setup for our location
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?
    
    let APP_ID = "48E0C0BD-4D5D-7547-FFD1-C6819D10B800"
    let API_KEY = "AA407415-008C-0F4C-FF10-C8E3966D9600" // aka API KEY
    let VERSION_NUM = "v1"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true // signals to FB that there should be local persistence as well for when we're offline
        backendless!.initApp(APP_ID, apiKey: API_KEY)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
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
        
        let result = FBSDKApplicationDelegate.sharedInstance().application(app, open: url,
                                                                           sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
                                                                           annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return result
    }
    
}

