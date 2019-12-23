//
//  TodayViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import FirebaseFirestore

class TodayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var marketLabel: UILabel!
    
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile(notification:)), name: NSNotification.Name(rawValue: AuthenticationController.NOTIFICATION_UPDATED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(marketUpdated), name: NSNotification.Name("MARKET_UPDATED"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(profilePhotoUpdated), name: NSNotification.Name("PROFILE_NEW_PHOTO"), object: nil)
        
       
        tableTopConstraint.constant = 63
        UserMessagingController.requestPermissionRemoteNotifications()
        
        // Force user to add a profile photo
        if let userProfileLocation:URL = AuthenticationController.user?.photoURL {
            let placeholderImage:UIImage? = nil // UIImage(named: "placeholder.jpg")
            profileImageView.sd_setImage(with: userProfileLocation, placeholderImage: placeholderImage)

            // Require a display name
            if AuthenticationController.user?.displayName == nil || (AuthenticationController.user?.displayName?.isEmpty)!{
                if let firstName = UserDefaults.standard.object(forKey: "KEY_FIRST_NAME"), let lastName = UserDefaults.standard.object(forKey: "KEY_LAST_NAME") {
                    print("Loaded name: \(firstName) \(lastName)")
                }
                else {
                    let profileEditViewController:ProfileEditViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileEditViewController.self)) as! ProfileEditViewController

                    profileEditViewController.displayTitle = "Name"
                    profileEditViewController.oldValue = AuthenticationController.user?.displayName

                    navigationController?.pushViewController( profileEditViewController, animated: true)
                }
            }
        }
        else{
            let captureProfilePhotoViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: CaptureProfilePhotoViewController.self)) as! CaptureProfilePhotoViewController
            captureProfilePhotoViewController.isRequired = true
            present(captureProfilePhotoViewController, animated: true, completion: nil)
        }
        
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        
        marketLabel.text = MarketController.currentMarket
        
        
        if( MarketController.currentMarket != nil && MarketController.currentMarket != ""){
            EventsController.updateEvents { (events) in
                self.tableView.reloadData()
            }
        }
        else{
            LocationController.startLocationMonitoring()
        }
        
//        NetworkingController.recommendedPeople { (success) in
//            if success {
//                self.tableView.reloadData()
//            }
//        }
    }

    
    
    @objc
    func marketUpdated(){
        marketLabel.text = MarketController.currentMarket
        EventsController.updateEvents { (events) in
            self.tableView.reloadData()
        }
    }
    
    
    @objc
    func profilePhotoUpdated(){
        profileImageView.sd_setImage(with: AuthenticationController.user?.photoURL, completed: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func updateProfile(notification:Notification){
        
        if let userProfileLocation:URL = AuthenticationController.user?.photoURL{
        
            let placeholderImage:UIImage? = nil // UIImage(named: "placeholder.jpg")
            
            profileImageView.sd_setImage(with: userProfileLocation, placeholderImage: placeholderImage)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentProfileView(user:EAUser){
        let profileViewController:ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as! ProfileViewController
        
        profileViewController.profileUID = user.uid
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightOfCell:CGFloat = 100.0

        let eventsCount:Int = EventsController.currentEvents().count

        if( indexPath.row > 0 && indexPath.row < eventsCount+1){
            heightOfCell = 225.0
        }
        else{
            switch indexPath.row {
            case 0:
                heightOfCell = 110.0
//            case 1:
//                heightOfCell = 120.0
//            case EventsController.currentEvents().count + 2:
//                heightOfCell = 100.0
            default:
                heightOfCell = 100.0
            }
        }
        return heightOfCell
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if EventsController.currentEvents().count > 0 {
            return EventsController.currentEvents().count + 1
        }
        else{
            return 2
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventsCount:Int = EventsController.currentEvents().count
        
        if( indexPath.row > 0 && indexPath.row < eventsCount + 1){
        
            // TODO: Cell formatter
            let cell:NewsEventsTableViewCell = tableView.dequeueReusableCell(withIdentifier: NewsEventsTableViewCell.NewsEventsCellID)! as! NewsEventsTableViewCell
            
            let event:EAEvent = EventsController.currentEvents()[indexPath.row - 1]
            cell.eventTitleLabel.text = event.eventTopic
            cell.eventDescriptionLabel.text = Utility.convertDatabaseString(stringToConvert: event.eventDescription!)
            
            if event.eventHost?.isEmpty != true {
                cell.hostedByLabel.text = event.eventHost
                cell.hostedByConstraint.constant = 5
            }
            else {
                cell.hostedByConstraint.constant = -25
                cell.hostedByLabel.text = ""
            }
            
            // Setup time label
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "E MMM d @ h:mm a"
            let dateString = dayTimePeriodFormatter.string(from: event.eventDate!)
            cell.eventPlaceAndTimeLabel.text = dateString
            
            // Setup profile image tap action
            cell.profileImagebutton.tag = indexPath.row - 1
            cell.profileImagebutton.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
            
            if( event.eventOriginatorID != nil && event.eventOriginatorImage == nil){
                // TODO: refactoring into profile controller
                
                cell.organizerImageView.image = UIImage(named: "user-image-default")
                
                let stringURL = "\(WebServicesController.WEB_HOST)/users/\(event.eventOriginatorID!)/metadata"
                let url:URL = URL(string: stringURL)!
                Alamofire.request(url, headers: WebServicesController.authenticationHeader()).responseJSON { (response) in
                    if response.result.isSuccess {
                        if let dataInfo = response.result.value as? NSDictionary {
                            if let photoURLString = dataInfo["photoURL"] as? String {
                                let photoURL = URL(string: photoURLString)
                                cell.organizerImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "user-image-default"), completed: { (loadedImage, error, cacheType, url) in
                                    event.eventOriginatorImage = loadedImage
                                })
                            }
                        }
                    }
                    else{
                        print(response.error!)
                    }
                }
                cell.organizerImageView.layer.masksToBounds = true
                cell.organizerImageView.layer.cornerRadius = cell.organizerImageView.frame.width/2
            }
            else if( event.eventOriginatorImage != nil ){
                cell.organizerImageView.image = event.eventOriginatorImage
            }
            
            return cell
        }
        else{
            switch indexPath.row {
            case 0:
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ActionItemCellID")!
                return cell
//            case 1:
//                let cell:MeetPeopleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PeopleToMeetCellID")! as! MeetPeopleTableViewCell
//
//
//                // TODO: Improve
//                for (index, currentUser) in NetworkingController.recommendedUsers.enumerated(){
//                    let imageView:EAImageView = cell.value(forKey: "person\(index + 1)ImageView") as! EAImageView
//                    if let profileURL:URL = (currentUser).photoURL {
//                        imageView.sd_setImage(with: profileURL, completed: nil)
//                        imageView.isHidden = false
//                        imageView.user = currentUser as? User
//                    }
//                }
//                return cell
////            case eventsCount + 2:
////                cell = tableView.dequeueReusableCell(withIdentifier: "StatsCellID")!
            default:
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "NoEventsCellID")!
                return cell
            }
        
            return tableView.dequeueReusableCell(withIdentifier: "ActionItemCellID")!
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let eventsCount:Int = EventsController.currentEvents().count
        
        if( indexPath.row > 0 && indexPath.row < eventsCount + 1){
            let eventDetailsViewController:EventDetailsViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: EventDetailsViewController.self)) as! EventDetailsViewController
            let event:EAEvent = EventsController.currentEvents()[indexPath.row - 1]
            eventDetailsViewController.event = event
            self.navigationController?.pushViewController(eventDetailsViewController, animated: true)
        }
        else{
            switch indexPath.row {
            case 0:
                let addEventViewController:AddEventViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: AddEventViewController.self)) as! AddEventViewController
                self.navigationController?.pushViewController(addEventViewController, animated: true)
            case 1:
                print("not yet implemented")
            case eventsCount + 2:
                print("not yet implemented")
            default:
                print("not yet implemented")
            }
        }
    }
    
    
    
    @IBAction func showProfile(_ sender: Any) {
        let profileViewController:ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as! ProfileViewController
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    
    @objc
    func profileImageTapped(_ sender: Any) {
        let profileViewController:ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as! ProfileViewController
        
        let event:EAEvent = EventsController.currentEvents()[(sender as AnyObject).tag]
        profileViewController.profileUID = event.eventOriginatorID
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
}
