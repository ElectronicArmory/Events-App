//
//  UserMessagingController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import EventKit



class UserMessagingController: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {

    static let instance:UserMessagingController = UserMessagingController()
    
    
    
    struct NotificationPermissions {
        static let Authorized:Notification.Name = Notification.Name("NOTIFICATIONS_PERMISSIONS_AUTHORIZED")
        static let Denied:Notification.Name = Notification.Name("NOTIFICATIONS_PERMISSIONS_DENIED")
    }
    
    
    
    static func alertUser(viewController:UIViewController, title:String, message:String){
        let alertController:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    
    static func activateEventReminders(){
        
        deactivateEventReminders()
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Events"
        content.body = "Check out your events for today."
        content.sound = UNNotificationSound.default
        
        for weekday in 2 ... 6 {
            var dateComponents = DateComponents()
            dateComponents.hour = 8
            dateComponents.minute = 0
            dateComponents.weekday = weekday
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
            var reminderWeekdayID:String
            switch weekday{
                case 2: reminderWeekdayID = "LOCAL_NOTIFICATION_EVENT_REMINDER_MON"
                case 3: reminderWeekdayID = "LOCAL_NOTIFICATION_EVENT_REMINDER_TUE"
                case 4: reminderWeekdayID = "LOCAL_NOTIFICATION_EVENT_REMINDER_WED"
                case 5: reminderWeekdayID = "LOCAL_NOTIFICATION_EVENT_REMINDER_THUR"
                case 6: reminderWeekdayID = "LOCAL_NOTIFICATION_EVENT_REMINDER_FRI"
                default: reminderWeekdayID = "LOCAL_NOTIFICATION_EVENT_REMINDER_FRI"
            }
        
            let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: reminderWeekdayID, content: content, trigger: trigger)
        
            center.add(notificationRequest, withCompletionHandler: { (error) in
                if let error = error {
                    // Something went wrong
                    print(error)
                }
            })
        }
    }
    
    
    static func deactivateEventReminders(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    static func startLoadingHUD(message:String){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        let activityData:ActivityData = ActivityData(size: CGSize(width: 100, height: 100),
//                                                     message: message,
//                                                     messageFont: UIFont.systemFont(ofSize: 14),
//                                                     messageSpacing: 2,
//                                                     type: NVActivityIndicatorType.circleStrokeSpin,
//                                                     color: UIColor.white,
//                                                     padding: 10.0,
//                                                     displayTimeThreshold: 4,
//                                                     minimumDisplayTime: 2,
//                                                     backgroundColor: UIColor(red: 221/255, green: 0.0, blue: 0.0, alpha: 0.8),
//                                                     textColor: UIColor.white)
//        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
    }
    
    
    static func stopLoadingHUD(){
//        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    
    static func addEventToCalendar( eventToAdd:EAEvent ){
        guard eventToAdd.eventDate != nil && eventToAdd.eventTopic != nil else {
            return
        }
        
        let store = EKEventStore()
        store.requestAccess(to: .event) {(granted, error) in
            if !granted { return }
            let event = EKEvent(eventStore: store)
            event.title = eventToAdd.eventTopic
            event.notes = eventToAdd.eventDescription
            event.startDate = eventToAdd.eventDate!
            
            event.url = eventToAdd.eventVirtualMeetingURL
            
            if( eventToAdd.eventLocation != nil ){
                event.location = "\(eventToAdd.eventLocation?.addressOne ?? ""), \(eventToAdd.eventLocation?.city ?? ""), \(eventToAdd.eventLocation?.state ?? "") \(eventToAdd.eventLocation?.zip ?? "")"
            }
            
//            event.addAlarm(EKAlarm(absoluteDate: Date(timeInterval: -1800, since: eventToAdd.eventDate!)))
            
            if eventToAdd.eventEndDate == nil {
//                event.endDate = Date(timeInterval: 3600, since: eventToAdd.eventDate!)
            }
            else{
                event.endDate = eventToAdd.eventEndDate
            }
            
            event.calendar = store.defaultCalendarForNewEvents

            do {
                try store.save(event, span: .thisEvent, commit: true)
            } catch {
                // Display error to user
            }
        }
    }
    
    
    
//    static func removeEvent( eventToRemove:Event ){
//        let store = EKEventStore()
//        store.requestAccessToEntityType(EKEntityTypeEvent) {(granted, error) in
//            if !granted { return }
//            let event = store.eventWithIdentifier( eventToRemove.eventID )
//            if event != nil {
//                do {
//                    try store.removeEvent(event, span: .ThisEvent, commit: true)
//                } catch {
//                    // Display error to user
//                }
//            }
//        }
//    }
    
    
    
    static func requestPermissionRemoteNotifications(){
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = UserMessagingController.instance
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if( error != nil ){
                    print(error!)
                }
                else{
                    if( isAuthorized ){
                        print("authorized")
                        NotificationCenter.default.post(Notification(name: NotificationPermissions.Authorized))
                    }
                    else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "Push Notifications", message: "Push notifications are turned off.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Turn on push notifications", style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let viewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                viewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage)
        //        UserMessagingController.alertUser(viewController: <#T##UIViewController#>, title: <#T##String#>, message: <#T##String#>)
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let token = Messaging.messaging().fcmToken
        //        print("FCM token: \(token ?? "")")
        ProfileController.updateToken(fcmToken: token!)
    }
    
}
