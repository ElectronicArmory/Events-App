//
//  LocationController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuth


class LocationController: NSObject, CLLocationManagerDelegate {

    static let instance:LocationController = LocationController()
    static let locationManager:CLLocationManager = CLLocationManager()
    
    static var currentLocation:CLLocation?
    
    static var isMonitoring:Bool = false
    
    
    
    struct LocationPermissions{
        static let AUTHORIZED:Notification.Name = Notification.Name("LOCATION_PERMISSIONS_CHANGED_AUTHORIZED")
        static let DENIED:Notification.Name = Notification.Name("LOCATION_PERMISSIONS_CHANGED_DENIED")
    }
    
    static func requestLocationPermission(){
        locationManager.delegate = instance
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    static func startLocationMonitoring(){
        if !isMonitoring {
            isMonitoring = true
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = instance
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 1000.0
            
            locationManager.startUpdatingLocation()
        }
    }
    
    static func stopLocationMonitoring(){
        if( isMonitoring ){
            isMonitoring = false
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized")
            NotificationCenter.default.post(Notification(name: LocationPermissions.AUTHORIZED))
        case .denied:
            
            let alert = UIAlertController(title: "Location Service", message: "Location service needs to be turned on in order to show you events in your area. Accuracy is limited to about half a mile.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Turn on location services", style: .default, handler: { (alertAction) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        // Checking for setting is opened or not
                        print("Setting is opened: \(success)")
                    })
                }
            }))
            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                print("user denied")
            }))
            let viewController = UIApplication.shared.keyWindow!.rootViewController
            DispatchQueue.main.async {
                viewController?.present(alert, animated: true, completion: nil)
            }
        case .notDetermined, .restricted:
            print("denied")
            NotificationCenter.default.post(Notification(name: LocationPermissions.DENIED))
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if LocationController.currentLocation == nil {
            setLocationData(locations[0])
        }
        else {
            let newLocation = locations[0]
            let distance = LocationController.currentLocation?.distance(from: newLocation)
        
            if distance! > 1000.0 {
                setLocationData(newLocation)
            }
        }
    }
    
    
    func setLocationData(_ newLocation:CLLocation){
        LocationController.currentLocation = newLocation
        syncLocation(LocationController.currentLocation!)
        
        NotificationCenter.default.post(name: NSNotification.Name("LOCATION_UPDATED"), object: nil)
    }
    
    
    func syncLocation(_ location:CLLocation ){
        ProfileController.updateUserPrivateInfo([
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "altitude": location.altitude,
            "latlong": GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        ])
    }
    
    
}
