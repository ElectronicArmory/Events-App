//
//  EventsController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFunctions
import Alamofire
import FirebaseAuth



class EventsController: NSObject {

    static let db = Firestore.firestore()
    
    
    fileprivate static var events:Array<EAEvent> = Array()
    
    static var eventAttendeeRequests:Array<EventAttendeeRequest> = Array()
    fileprivate static var loadedEventRequests:Int = 0
    
    static let kEventsDatabase:String = "events"
    static let kEventAttendeesDatabase:String = "event_attendees"
    
    
    static var currentlyLoadingEvents:Bool = false
    
    
    
    static func createNewEvent(_ newEvent:EAEvent){
        
        let eventInfo:Dictionary = EventsController.jsonFromEvent(event: newEvent)
        
        var newEventReference: DocumentReference? = nil
        newEventReference = db.collection(kEventsDatabase).addDocument(data: eventInfo) { (error) in
            if( error != nil ){
                print("Error: \(error!)")
                UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Error creating new event", message: (error?.localizedDescription)!)
                return
            }
            
            print("Document added with ID: \(newEventReference!.documentID)")
            db.collection(kEventAttendeesDatabase).document(newEventReference!.documentID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
//                    let source = document.metadata.hasPendingWrites ? "Local" : "Server"
//                    print("\(source) data: \(document.data()!)")
            }
            print("Added event")
        }
    }
    
    
    
    static func editEvent(event:EAEvent, completion: @escaping (Bool) -> Void){
        if let eventID = event.eventID {
            db.collection("events").document(eventID).setData(jsonFromEvent(event: event), completion: { (error) in
                if error != nil {
                    print("Error changing event: \(eventID)")
                    print(error!)
                    completion(false)
                }
                else {
                    completion(true)
                }
            })
        }
    }
    
    
    
    static func removeEvent(_ event:EAEvent, completion: @escaping (Bool) -> Void){
        if let eventID = event.eventID {
            db.collection("events").document(eventID).delete { (error) in
                if error != nil {
                    print("Error deleting event: \(eventID)")
                    print(error!)
                    completion(false)
                }
                else{
                    completion(true)
                }
            }
        }
    }
    
    
    
    static func joinEvent(viewController:UIViewController, event:EAEvent, completion: @escaping(Bool) -> Void){
        
        let headers:HTTPHeaders = WebServicesController.authenticationHeader()
        let urlString:String = "https://us-central1-boisestate-example.cloudfunctions.net/app/events/\(event.eventID!)/join"
        let url:URL = URL(string: urlString)!
        do{
            UserMessagingController.startLoadingHUD(message: "Requesting to join meeting...")
            
            // TODO: Put in web services
            let urlRequest:URLRequest = try URLRequest(url: url, method: .post, headers: headers)
            Alamofire.request(urlRequest).responseJSON { (response) in
                
                UserMessagingController.stopLoadingHUD()
                
                if (response.result.isSuccess == true ){
                    if(response.result.value) != nil{
                        if let dataInfo = response.result.value as? NSDictionary {
                            
                            // Handle errors if response contains messages
                            if( dataInfo["message"] != nil ){
                                if( dataInfo["message"] is String ){
                                    let message:String = dataInfo["message"] as! String

                                    UserMessagingController.alertUser(viewController: viewController, title: "Meeting Request", message: message )
                                }
                                else{
//                                    if let _:NSDictionary = dataInfo["message"] as? NSDictionary {
                                        UserMessagingController.alertUser(viewController: viewController, title: "Meeting Request", message: "Success.")
//                                    }
                                }
                                return
                            }
                            else{
                                UserMessagingController.alertUser(viewController: viewController, title: "Success!", message: "We've marked you down as going.")
                            }
                        }
                        completion(true)
                    }
                    else{
                        print(response.result)
                        UserMessagingController.alertUser(viewController: viewController, title: "Unknown error!", message: response.result.value as! String)
                        completion(false)
                    }
                }
                else{
                    // TODO: Handle error and expired token
                }
            }
        }
        catch{
            print(error)
            UserMessagingController.stopLoadingHUD()
        }
    }
    
    
    
    static func jsonFromEvent(event:EAEvent)->Dictionary<String, Any>{
        let locationInfo:Dictionary = [
            "locationName": event.eventLocation?.locationName,
            "addressOne": event.eventLocation?.addressOne,
            "addressTwo": event.eventLocation?.addressTwo,
            "city": event.eventLocation?.city,
            "state": event.eventLocation?.state,
            "zip": event.eventLocation?.zip
        ]
        
        let eventInfo:Dictionary = [
            "originatorId": event.eventOriginatorID as Any,
            "startDate": event.eventDate!,
            "endDate": event.eventEndDate!,
            "topic": event.eventTopic!,
            "description": event.eventDescription!,
            "ticketUrl": event.eventTicketURL?.absoluteString ?? "",
            "hostedBy": event.eventHost ?? "",
            "meetingUrl": event.eventVirtualMeetingURL?.absoluteString ?? "",
            "location": locationInfo,
            "market": MarketController.currentMarket!]
        return eventInfo
    }
    
    
    
    static func updateEvents( completion: @escaping (Array<EAEvent>) -> Void ){
        if currentlyLoadingEvents == true {
            return
        }
        
        currentlyLoadingEvents = true
        
        let db = Firestore.firestore()
        
        db.collection("events").whereField("market", isEqualTo: MarketController.currentMarket!).order(by: "startDate", descending: true).whereField("startDate", isGreaterThan: Date())
            .addSnapshotListener { querySnapshot, error in
                
                currentlyLoadingEvents = false
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Error getting events", message: (error?.localizedDescription)!)
                    let errorCode = (error! as NSError).code
                    if( errorCode == 7){
                        // TODO: Need to log in again
                        RootViewController.loadLoginView()
                    }
                    return
                }
                
                EventsController.events.removeAll(keepingCapacity: true)
                
                documents.forEach({ (snapshot) in
                    
                    let documentData = snapshot.data()
                    
                    let event:EAEvent = EAEvent()
                    event.eventID = snapshot.documentID
                    event.eventTopic = documentData["topic"] as? String
                    event.eventDescription = documentData["description"] as? String
                    
                    let startDate = documentData["startDate"] as? Timestamp
                    event.eventDate = startDate?.dateValue()
                    event.eventEndDate = documentData["endDate"] as? Date
                    
                    event.eventHost = (documentData["hostedBy"] as? String) ?? ""
                    
                    if let ticketURLString:String = documentData["ticketUrl"] as? String {
                        event.eventTicketURL = URL(string: ticketURLString) ?? nil
                    }
                    
                    if let meetingURLString:String = documentData["meetingUrl"] as? String {
                        event.eventVirtualMeetingURL = URL(string: meetingURLString) ?? nil
                    }
                    
                    if let eventLocation = documentData["location"] as? Dictionary<AnyHashable, String>{
                        
                        // TODO: Factory
                        event.eventLocation = EALocation()
                        event.eventLocation?.locationName = eventLocation["locationName"]
                        event.eventLocation?.addressOne = eventLocation["addressOne"]
                        event.eventLocation?.addressTwo = eventLocation["addressTwo"]
                        event.eventLocation?.city = eventLocation["city"]
                        event.eventLocation?.state = eventLocation["state"]
                        event.eventLocation?.zip = eventLocation["zip"]
                    }
                    else{
                        event.eventLocation = EALocation()
                        event.eventLocation?.locationName = documentData["location"] as? String
                    }

                    event.eventOriginatorID = documentData["originatorId"] as? String
                    self.events.insert(event, at: 0)
                })
                
                NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_NEW_EVENTS"), object: EventsController.events)
                completion(EventsController.events)
        }
    }
    
    
    
    static func currentEvents() -> Array<EAEvent>{
        return events
    }
    
    
    
    static func attendeesForEventID(eventID:String, completion: @escaping (Array<String>) -> Void ){
        db.collection("event_attendees").whereField("eventId", isEqualTo: eventID).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Error getting attendees", message: (error?.localizedDescription)!)
                let errorCode = (error! as NSError).code
                if( errorCode == 7){
                    // TODO: Need to log in again
                }
                return
            }
            
            // TODO: Make into a set
            var eventAttendees:Array<String> = Array<String>()
            
            documents.forEach({ (snapshot) in
                
                let documentData = snapshot.data()
                
                let attendeeID:String = (documentData["attendeeId"] as? String)!
                eventAttendees.insert(attendeeID, at: 0)
            })
            
            NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_ATTENDEES_RECEIVED"), object: eventAttendees)
            completion(eventAttendees)
        }
    }
    
    
    
    static func profileForUserID(userID:String, completion: @escaping (EAUser) -> Void ){
        db.collection("users").document(userID).getDocument(completion: { (snapshot, error) in
            
            if( error != nil ){
                UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Error getting profile for ID", message: (error?.localizedDescription)!)
            }
            
            
            
            let documentData = snapshot?.data()
            
            guard documentData != nil else {
                return
            }
            
            
            let user:EAUser = EAUserFactory.userFromJSON(userInfo: snapshot!)

            Alamofire.request(URL(string: "https://us-central1-bsu-example.cloudfunctions.net/app/users/\(userID)/metadata")!, headers: WebServicesController.authenticationHeader()).responseJSON(completionHandler: { (response) in
                
                if let jsonResponse = response.result.value as? NSDictionary {
                    let photoURL:String = jsonResponse["photoURL"] as! String
                    user.photoURL = URL(string: photoURL)
                    
                    NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_USER_PROFILE_RECEIVED"), object: user)
                    completion(user)
                }
            })
            
        })
    }
    
    
    
    static func pendingEventAttendees(completion:@escaping () -> Void){
        
        db.collection("event_attendees").whereField("originatorId", isEqualTo: (AuthenticationController.user?.uid)!).whereField("attendance_status", isEqualTo: "pending").getDocuments { (snapshot, error) in
            
            if( error != nil ){
                print(error!)
                return
            }
            
            eventAttendeeRequests.removeAll(keepingCapacity: false)
        
            let documents = (snapshot?.documents)!
            let totalCount = documents.count
            EventsController.loadedEventRequests = 0
            
            for document in documents {
                print(document.data())
                let attendeeRequest = document.data()
                
                let newEventAttendeeRequest:EventAttendeeRequest = EventAttendeeRequest()
                newEventAttendeeRequest.attendeeUID = attendeeRequest["attendeeId"] as? String
                newEventAttendeeRequest.originatorUID = attendeeRequest["originatorId"] as? String
                newEventAttendeeRequest.attendeeDisplayName = attendeeRequest["attendeeDisplayName"] as? String
                newEventAttendeeRequest.eventID = attendeeRequest["eventId"] as? String
                newEventAttendeeRequest.timestamp = attendeeRequest["timestamp"] as? Timestamp // TODO: fix timestamp
                
                if let profileURLString = attendeeRequest["attendeeProfileUrl"] as? String {
                    newEventAttendeeRequest.attendeeProfileURL = URL(string: profileURLString) // TODO: check not nil
                }
                
                newEventAttendeeRequest.event.eventID = attendeeRequest["eventId"] as? String
                db.collection("events").document(newEventAttendeeRequest.event.eventID!).getDocument(completion: { (snapshot, error) in
                    guard error == nil else{
                        return
                    }
                    
                    let documentData = (snapshot?.data())!
                    
                    newEventAttendeeRequest.event.eventTopic = documentData["topic"] as? String
                    newEventAttendeeRequest.event.eventDescription = documentData["description"] as? String
//                    newEventAttendeeRequest.event.eventDate = documentData["date"] as? Date
                    
                    if let eventLocationInfo = documentData["location"] as? Dictionary<AnyHashable, String>{
                    
                        newEventAttendeeRequest.event.eventLocation = eventLocationFactory(eventLocationInfo: eventLocationInfo)
                    
                        newEventAttendeeRequest.event.eventOriginatorID = documentData["originatorId"] as? String
                    }
                    EventsController.loadedEventRequests = EventsController.loadedEventRequests + 1
                    
                    if EventsController.loadedEventRequests >= totalCount {
                        completion()
                    }
                })
                
                eventAttendeeRequests.append(newEventAttendeeRequest)
            }
        }
    }
    
    
    
    class func eventLocationFactory(eventLocationInfo:Dictionary<AnyHashable, String>) -> EALocation{
        let location = EALocation()
        
        location.addressOne = eventLocationInfo["addressOne"]
        location.addressTwo = eventLocationInfo["addressTwo"]
        location.city = eventLocationInfo["city"]
        location.state = eventLocationInfo["state"]
        location.zip = eventLocationInfo["zip"]
        
        return location
    }
}
