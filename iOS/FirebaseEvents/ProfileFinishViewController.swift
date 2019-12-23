//
//  ProfileFinishViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

import Firebase

import UserNotifications
import CoreLocation


class ProfileFinishViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var notificationsPermissionButton: EAButton!
    @IBOutlet weak var locationServicesPermissionButton: EAButton!
   
    @IBOutlet weak var finishButton: EAButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Notification UI
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationsAuthorized), name: UserMessagingController.NotificationPermissions.Authorized, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationsDenied), name: UserMessagingController.NotificationPermissions.Denied, object: nil)
        
        notificationsPermissionButton.isEnabled = false
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Either denied or notDetermined
                DispatchQueue.main.async {
                    self.notificationsPermissionButton.setTitle("Enable Notifications", for: UIControl.State.normal)
                    self.notificationsPermissionButton.isEnabled = true
                }
            }
            else{
                DispatchQueue.main.async {
                    self.notificationsPermissionButton.setTitle("Notifications ✓", for: UIControl.State.normal)
                }
            }
        }
        
        // Setup Location Services UI
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationPermissionAuthorized), name: LocationController.LocationPermissions.AUTHORIZED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationPermissionDenied), name: LocationController.LocationPermissions.DENIED, object: nil)
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationServicesPermissionButton.setTitle("Enable Location Services", for: UIControl.State.normal)
            case .authorizedAlways, .authorizedWhenInUse:
                locationServicesPermissionButton.setTitle("Location Services ✓", for: .normal)
                locationServicesPermissionButton.isEnabled = false
            }
        }
        else {
            print("Location services are not enabled")
        }
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func notificationsAuthorized(){
        // TODO: main thread
        DispatchQueue.main.async {
            self.notificationsPermissionButton.isEnabled = false
            self.notificationsPermissionButton.setTitle("Notifications ✓", for: .normal)
        }
    }
    
    
    @objc func notificationsDenied(){
        DispatchQueue.main.async {
            self.notificationsPermissionButton.isEnabled = true
            self.notificationsPermissionButton.setTitle("Enable Notifications", for: .normal)
        }
    }
    
    
    
    @objc func locationPermissionAuthorized(){
        locationServicesPermissionButton.isEnabled = false
        locationServicesPermissionButton.setTitle("Location Services ✓", for: .normal)
    }
    
    
    @objc func locationPermissionDenied(){
        locationServicesPermissionButton.isEnabled = true
        locationServicesPermissionButton.setTitle("Enable Location Services", for: .normal)
    }
    
    
    
    @IBAction func notificationPermissionTapped(_ sender: Any) {
        UserMessagingController.requestPermissionRemoteNotifications()
    }
    
    
    @IBAction func locationServicesPermissionTapped(_ sender: Any) {
        LocationController.requestLocationPermission()
    }
    
    
    @IBAction func finishTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        RootViewController.loadTodayViewController()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
