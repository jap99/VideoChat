//
//  MapVC.swift
//  cleanchat
//
//  Created by Javid Poornasir on 4/19/18.
//  Copyright © 2018 Javid Poornasir. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

     @IBOutlet weak var mapView: MKMapView!
     @IBOutlet weak var cancelButton: UIButton!
 
    var location: CLLocation! // used to pass our location to our mapView
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        var region = MKCoordinateRegion()
        region.center.latitude = location.coordinate.latitude
        region.center.longitude = location.coordinate.longitude
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        
        mapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        
    }
    
    

    // MARK: IBActions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
   
}
