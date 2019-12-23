//
//  EventDetailsViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import Alamofire


class EventDetailsViewController: UIViewController {

    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    
    @IBOutlet weak var eventDateLabel: UILabel!
//    @IBOutlet weak var eventEndDateLabel: UILabel!
    @IBOutlet weak var eventAddressTextView: UITextView!
    
    @IBOutlet weak var attendeeImageView1: UIImageView!
    @IBOutlet weak var attendeeImageView2: UIImageView!
    @IBOutlet weak var attendeeImageView3: UIImageView!
    @IBOutlet weak var attendeeImageView4: UIImageView!
    @IBOutlet weak var attendeeImageView5: UIImageView!
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    var event:EAEvent?
    
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var marketLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var editEventButton: EAButton!
    
    @IBOutlet weak var addToCalendarButton: UIButton!
    
    @IBOutlet weak var ticketsView: UIView!
    @IBOutlet weak var ticketsURLButton: EAButton!
    @IBOutlet weak var ticketTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var meetingURLButton: UIButton!
    @IBOutlet weak var meetingURLTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var virtualMeetingView: UIView!
    @IBOutlet weak var hostLabel: UILabel!
    
    @IBOutlet weak var eventDescriptionTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var ownerGoingImageView: EAImageView!
    @IBOutlet weak var goingLabel: UILabel!
    
    @IBOutlet weak var removeEventButton: EAButton!
    
    @IBOutlet weak var rsvpView: UIView!
    @IBOutlet weak var goingView: UIView!
    
    @IBOutlet weak var ownerView: UIView!
    @IBOutlet weak var goingButton: UIButton!
    var usersToList:[EAUser]? = nil
    var hostUser:EAUser? = nil
    
    
    @IBOutlet weak var goingTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard event != nil else {
            return
        }
        
        navigationController?.isNavigationBarHidden = true
        marketLabel.text = MarketController.currentMarket
        
        NotificationCenter.default.addObserver(self, selector: #selector(marketUpdated), name: NSNotification.Name("MARKET_UPDATED"), object: nil)
        
        profileImageView.sd_setImage(with: AuthenticationController.user?.photoURL, completed: nil)
        
        eventTitleLabel.text = event?.eventTopic
        
        
        if let originatorID = event!.eventOriginatorID {
            let stringURL = "\(WebServicesController.WEB_HOST)/users/\(originatorID)/metadata/"
            let url:URL = URL(string: stringURL)!
            Alamofire.request(url, headers: WebServicesController.authenticationHeader()).responseJSON { (response) in
                if response.result.isSuccess {
                    if let dataInfo = response.result.value as? NSDictionary {
                        if let displayName = dataInfo["displayName"] {
                            self.hostLabel.text = "Hosted by \(displayName as! String)"
                            let urlString:String = dataInfo["photoURL"] as! String
                            let photoURL:URL = URL(string: urlString)!
                            self.ownerGoingImageView.sd_setImage(with: photoURL, completed: nil)
                        }
                    }
                }
            }
        }
        
//        if let hostString = event?.eventHost {
//            hostLabel.text = hostString
//        }
//        else{
//            hostLabelConstraint.constant = -20
//        }
        
        eventDescriptionLabel.text = Utility.convertDatabaseString(stringToConvert: (event?.eventDescription)!)
        
//        if eventDescriptionLabel.text?.isEmpty == true {
//            readMoreButton.isHidden = true
//        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM d @ h:mm a"
        
        let dateString = dateFormatter.string(from: event!.eventDate!)
        eventDateLabel.text = dateString
        
        
        if event?.eventEndDate != nil {
            let endDateFormatter = DateFormatter()
            endDateFormatter.dateFormat = "h:mm a"
            let dateEndString = endDateFormatter.string(from: (event?.eventEndDate!)!)
            eventDateLabel.text = eventDateLabel.text! + " - " + dateEndString
        }
        
        
        var eventLocationDescription:String
        
        // TODO: More robust checking
        if event?.eventLocation?.locationName != nil && event?.eventLocation?.locationName != "" {
            eventLocationDescription = "\((event?.eventLocation?.locationName)!)"
            
            if( event?.eventLocation?.addressOne != nil && event?.eventLocation?.addressOne != "" ){
                eventLocationDescription.append("\n\((event?.eventLocation?.addressOne)!)")
            }
            if( event?.eventLocation?.addressTwo != nil && event?.eventLocation?.addressTwo != "" ){
                eventLocationDescription.append("\n\((event?.eventLocation?.addressTwo)!)")
            }
            if( event?.eventLocation?.city != nil && event?.eventLocation?.city != "" ){
                eventLocationDescription.append("\n\((event?.eventLocation?.city)!),")
            }
            if( event?.eventLocation?.state != nil && event?.eventLocation?.state != "" ){
                eventLocationDescription.append(" \((event?.eventLocation?.state)!)")
            }
            if( event?.eventLocation?.zip != nil && event?.eventLocation?.zip != "" ){
                eventLocationDescription.append(" \((event?.eventLocation?.zip)!)")
            }

        }
        else{
            eventLocationDescription = "Not specified"
        }
        
        eventAddressTextView.text = eventLocationDescription
        
        // Tickets
        if event?.eventTicketURL != nil {
            ticketsURLButton.isHidden = false
            ticketsView.isHidden = false
        }
        else{
            ticketsURLButton.isHidden = true
            ticketsView.isHidden = true
            eventDescriptionTopConstraint.constant = eventDescriptionTopConstraint.constant - 42
            meetingURLTopConstraint.constant = 8
        }
        
        // Virtual Meeting
        if event?.eventVirtualMeetingURL != nil {
            meetingURLButton.isHidden = false
            virtualMeetingView.isHidden = false
        }
        else{
            meetingURLButton.isHidden = true
            virtualMeetingView.isHidden = true
            eventDescriptionTopConstraint.constant = eventDescriptionTopConstraint.constant - 42
        }
        
        
        // Going
        EventsController.attendeesForEventID(eventID: (event?.eventID)!) { (attendeeIDArray) in
            var attendeeIDs = attendeeIDArray
            
            if( self.event?.eventOriginatorID != nil ){
                attendeeIDs.insert(self.event!.eventOriginatorID!, at: 0)
            }
            
            var index:Int = 0
            self.usersToList = [EAUser]()
            for attendeeID in attendeeIDs.prefix(5){
                
                if ( attendeeID == AuthenticationController.user?.uid ){
                    self.rsvpView.isHidden = true
//                    self.goingTopConstraint.constant = 10
                }
                
                let currentIndex = index
                let stringURL = "\(WebServicesController.WEB_HOST)/users/\(attendeeID)/metadata"
                let url:URL = URL(string: stringURL)!
                Alamofire.request(url, headers: WebServicesController.authenticationHeader()).responseJSON { (response) in
                    if response.result.isSuccess {
                        if let dataInfo = response.result.value as? NSDictionary {
                            let newUser:EAUser = EAUserFactory.userFromJSON(userInfo: dataInfo)
//                            let newUser:EAUser = EAUserFactory.usersFromJSON(usersArray: <#T##Array<Dictionary<AnyHashable, Any>>#>)
                            if (newUser.uid == self.event?.eventOriginatorID){
                                self.hostUser = newUser
                            }
                            let photoURLString = dataInfo["photoURL"]! as! String
                            let photoURL = URL(string: photoURLString)
                          
                            
                            self.usersToList?.append(newUser)
                            switch(currentIndex){
                            case 1:
                                self.attendeeImageView1.isHidden = false
                                self.attendeeImageView1.sd_setImage(with: photoURL, completed: nil)
                            case 2:
                                self.attendeeImageView2.isHidden = false
                                self.attendeeImageView2.sd_setImage(with: photoURL, completed: nil)
                            case 3:
                                self.attendeeImageView3.isHidden = false
                                self.attendeeImageView3.sd_setImage(with: photoURL, completed: nil)
                            case 4:
                                self.attendeeImageView4.isHidden = false
                                self.attendeeImageView4.sd_setImage(with: photoURL, completed: nil)
                            case 5:
                                self.attendeeImageView5.isHidden = false
                                self.attendeeImageView5.sd_setImage(with: photoURL, completed: nil)
                            default:
                                print("default")
                            }
                        }
                    }
                }
                index = index + 1
            }
        }
        
        if event?.eventOriginatorID == AuthenticationController.user?.uid {
            ownerView.isHidden = false
            rsvpView.isHidden = true
        }
        else{
            ownerView.isHidden = true
            rsvpView.isHidden = false
        }
        
//        ownerGoingImageView.image = event?.eventOriginatorImage
    }

    
    
    @objc
    func marketUpdated(){
        marketLabel.text = MarketController.currentMarket
    }
    
    
    
    @IBAction func editEventTapped(_ sender: Any) {
        
        let editEventViewController:AddEventViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: AddEventViewController.self)) as! AddEventViewController
        editEventViewController.event = self.event
        
        navigationController?.pushViewController(editEventViewController, animated: true)
    }
    
    
    
    @IBAction func duplicateEventTapped(_ sender: Any) {
        let duplicateEventViewController:AddEventViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: AddEventViewController.self)) as! AddEventViewController
        
        duplicateEventViewController.event = self.event
        duplicateEventViewController.isDuplicateEvent = true
        navigationController?.pushViewController(duplicateEventViewController, animated: true)
    }
    
    
    
    @IBAction func removeEventTapped(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Remove your event?", message: "Do you really want to remove your event?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Remove Event", style: .default, handler: { (alertAction) in
            if let currentEvent = self.event {
                EventsController.removeEvent(currentEvent) { (success) in
                    if success {
                        self.navigationController?.popToRootViewController(animated: true)
                        let confirmAlertController = UIAlertController(title: "Success", message: "Your event has successfully been removed.", preferredStyle: .alert)
                        confirmAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(confirmAlertController, animated: true, completion: nil)
                    }
                    else {
                        print("Removing event failure.")
                    }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            print("cancel")
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func addToCalendarTapped(_ sender: Any) {
        UserMessagingController.addEventToCalendar(eventToAdd: self.event!)
        
        addToCalendarButton.isHidden = true
        
        let alertController = UIAlertController(title: "Added to Calendar", message: "This event has been added to your calendar", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let dateString = dateFormatter.string(from: event!.eventDate!)
        
        let url = URL(string: "https://ElectronicArmory.com/")
        let items = [(event?.eventTopic)!, (event?.eventLocation?.locationName)!, "\((event?.eventLocation?.addressOne)!), \((event?.eventLocation?.addressTwo)!)", "\((event?.eventLocation?.city)!), \((event?.eventLocation?.state)!) \((event?.eventLocation?.zip)!)", dateString, url!, UIImage(named: "Icon")!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    
    @IBAction func locationTapped(_ sender: Any) {
        let addressString = "\((event?.eventLocation?.addressOne)!)+\((event?.eventLocation?.city)!),+\((event?.eventLocation?.state)!)+\((event?.eventLocation?.zip)!)"
        
        let escapedString = addressString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let addressURL:URL = URL(string: "https://maps.apple.com/?daddr=\(escapedString!)"){
            if UIApplication.shared.canOpenURL(addressURL){
                UIApplication.shared.open(addressURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func ticketsTapped(_ sender: Any) {
        if let urlToOpen = event?.eventTicketURL {
            if UIApplication.shared.canOpenURL(urlToOpen) {
                UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    
    @IBAction func meetingTapped(_ sender: Any) {
        if let urlToOpen = event?.eventVirtualMeetingURL {
            if UIApplication.shared.canOpenURL(urlToOpen) {
                UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    
    @IBAction func readMoreTapped(_ sender: Any) {
        let eventDescriptionViewController:EventDescriptionViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: EventDescriptionViewController.self)) as! EventDescriptionViewController
        
        eventDescriptionViewController.event = self.event
        
        navigationController!.pushViewController(eventDescriptionViewController, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func profileTapped(_ sender: Any) {
        let profileViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as! ProfileViewController
        profileViewController.user = AuthenticationController.user
        
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func goingTapped(_ sender: Any) {
        let peopleViewController:PeopleViewController = storyboard?.instantiateViewController(withIdentifier: "PeopleAttendingViewController") as! PeopleViewController
        peopleViewController.usersToList = usersToList
        self.navigationController?.pushViewController(peopleViewController, animated: true)
    }
    
    @IBAction func hostedByTapped(_ sender:UIButton){
        let profileViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as! ProfileViewController
        profileViewController.profileUID = hostUser?.uid
        profileViewController.user = hostUser
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @IBAction func joinMeetingTapped(_ sender: UIButton) {
        // eventID
        // userID
        EventsController.joinEvent(viewController: self, event: event!) { (isSuccessful) in
            if( isSuccessful ){
                UserMessagingController.addEventToCalendar(eventToAdd: self.event!)

                self.addToCalendarButton.isHidden = true
                
                let alertController = UIAlertController(title: "Success", message: "You have RSVPed to this event. The event was added to your calendar.", preferredStyle: .alert)
                if( self.event?.eventTicketURL != nil ){
                    alertController.addAction(UIAlertAction(title: "I have my ticket", style: .default, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Get ticket", style: .default, handler: { (action) in
                        DispatchQueue.main.async {
                            self.ticketsTapped(sender)
                        }
                    }))
                }
                else {
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                }
                self.present(alertController, animated: true, completion: nil)
                sender.isHidden = true
            }
        }
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
