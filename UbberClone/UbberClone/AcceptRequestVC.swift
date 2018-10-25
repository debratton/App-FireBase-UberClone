//
//  AcceptRequestVC.swift
//  UbberClone
//
//  Created by David E Bratton on 10/24/18.
//  Copyright © 2018 David Bratton. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class AcceptRequestVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func acceptRequestBtnPressed(_ sender: Any) {
        // UPDATE RIDE REQUEST
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat":self.driverLocation.latitude, "driverLon":self.driverLocation.longitude])
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
        
        // GIVE DIRECTIONS
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placeMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                    
                }
            }
        }
    }
    


}
