//
//  AddEventViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import CoreLocation


class AddEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var editEventButton: UIButton!
    @IBOutlet weak var eventHostTextField: UITextField!
    
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var eventEndDateTextField: UITextField!
    
    @IBOutlet weak var eventTopicTextField: UITextField!
    @IBOutlet weak var eventLocationTextField: UITextField!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventPublicSwitch: UISwitch!
    @IBOutlet weak var eventPublicLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    
    @IBOutlet weak var virtualMeetingURLTextField: UITextField!
    @IBOutlet weak var ticketsURLTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    let placeholderText:String = "Description"
    
    var event:EAEvent?
    var eventDate:Date = Date()
    var eventEndDate:Date = Date()
    
    var status:Bool = false
    var isNewEvent:Bool = true
    var isDuplicateEvent:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDateField()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // New Event
        if( event == nil ){
            event = EAEvent()
            isNewEvent = true
            editEventButton.setTitle("Create Event", for: .normal)
            eventDescriptionTextView.text = placeholderText
            eventDescriptionTextView.textColor = UIColor.lightGray
            eventDescriptionTextView.selectedTextRange = eventDescriptionTextView.textRange(from: eventDescriptionTextView.beginningOfDocument, to: eventDescriptionTextView.beginningOfDocument)
        }
        // Edit event
        else {
            isNewEvent = false
            editEventButton.setTitle("Save Changes", for: .normal)
            eventHostTextField.text = event?.eventHost
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d 'at' h:mm a"
            let dateString = dateFormatter.string(from: event!.eventDate!)
            eventDateTextField.text = dateString
            eventDate = event!.eventDate!
            eventEndDate = (event?.eventEndDate)!
            
            let dateEndFormatter = DateFormatter()
            dateEndFormatter.dateFormat = "MMMM d 'at' h:mm a"
            let dateEndString = dateEndFormatter.string(from: (event?.eventEndDate)!)
            eventEndDateTextField.text = dateEndString
            
            eventTopicTextField.text = event?.eventTopic
//            eventLocationTextField.text = event?.eventLocation
//            eventLocationLabel.text = event.event
//            eventPublicSwitch.text = event.event
//            eventPublicLabel.text = event.event
            eventDescriptionTextView.text = event?.eventDescription
            
            virtualMeetingURLTextField.text = event?.eventVirtualMeetingURL?.absoluteString
            ticketsURLTextField.text = event?.eventTicketURL?.absoluteString
        }
        
        if( isDuplicateEvent == true){
            event?.eventID = nil
            isNewEvent = true
            editEventButton.setTitle("Create Event", for: .normal)
        }
    }
    
    
    
    func setupDateField(){
        eventDate = Date().addingTimeInterval(24 * 60 * 60)
        
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.date = eventDate
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 15
        datePicker.addTarget(self, action: #selector(updateSelectedDate), for: .valueChanged)
        
        eventDateTextField.inputView = datePicker
        
        
        let dateEndPicker:UIDatePicker = UIDatePicker()
        dateEndPicker.date = eventEndDate
        dateEndPicker.datePickerMode = .dateAndTime
        dateEndPicker.minuteInterval = 15
        dateEndPicker.addTarget(self, action: #selector(updateSelectedEndDate), for: .valueChanged)
        eventEndDateTextField.inputView = dateEndPicker
    }
    
    
    
    @IBAction func eventPublicSwitchChangedValue(_ sender: Any) {
        if( eventPublicSwitch.isOn ){
            eventPublicLabel.text = "Others may join you."
        }
        else{
            eventPublicLabel.text = "This will be a private event."
        }
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 25
    }
    
    
    
    @objc func updateSelectedDate(sender: UIDatePicker){
        eventDate = sender.date
        updateDateTextField()
    }
    
    @objc func updateSelectedEndDate(sender: UIDatePicker){
        eventEndDate = sender.date
        updateEndDateTextField()
    }
    
    
    
    func updateDateTextField(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d 'at' h:mm a"
        let dateString = dateFormatter.string(from: eventDate)
        
        eventDateTextField.text = dateString
    }
    
    
    func updateEndDateTextField(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d 'at' h:mm a"
        let dateEndString = dateFormatter.string(from: eventEndDate)
        eventEndDateTextField.text = dateEndString
        //TODO: Add done above input view
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 255
    }
    
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                if textView.text != "" {
                    textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
                }
            }
        }
    }
    
    
    
    // MARK: - Keyboard Delegate methods
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if scrollView.frame.origin.y == 0{
                scrollView.frame.size.height -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if scrollView.frame.origin.y != 0{
                scrollView.frame.size.height += keyboardSize.height
            }
        }
    }
    
    
    
    // MARK: - IBAction methods
    @IBAction func changeLocationTapped(sender: UIButton) {
        let eventLocationViewController:EventLocationViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: EventLocationViewController.self)) as! EventLocationViewController
        
        if event?.eventLocation == nil {
            event?.eventLocation = EALocation()
        }
    
        eventLocationViewController.event = event
        
        navigationController?.pushViewController(eventLocationViewController, animated: true)
    }
    
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func createEventTapped(_ sender: Any) {
        // TODO: Check for proper location fields, not just addressOne
        if( (event?.eventLocation == nil || event?.eventLocation?.addressOne == nil)){
            if (virtualMeetingURLTextField.text!.isEmpty ){
                let alertView = UIAlertController(title: "Location Needed", message: "You need to provide a location, real or virtual for this meeting.", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                present(alertView, animated: true, completion: nil)
                
                return
            }
        }
        
        event?.eventDate = eventDate
        event?.eventEndDate = eventEndDate
        
        event?.eventHost = eventHostTextField.text
        
        if eventTopicTextField.text?.isEmpty != true {
            event?.eventTopic = eventTopicTextField.text
        }
        else{
            UserMessagingController.alertUser(viewController: self, title: "Error creating event", message: "The topic of your event is required.")
            return
        }
        event?.eventDescription = eventDescriptionTextView.text

        if ticketsURLTextField.text?.isEmpty != true {
            if Utility.verifyUrl( urlString: ticketsURLTextField.text! ) == true {
                
                event?.eventTicketURL = URL(string: ticketsURLTextField.text!)
            }
            else{
                UserMessagingController.alertUser(viewController: self, title: "Error creating event", message: "There was an issue with your ticket sales URL. Try entering it again. Make sure to include http:// or https:// before the URL.")
                return
            }
        }
        
        
        if virtualMeetingURLTextField.text?.isEmpty != true {
            if Utility.verifyUrl( urlString: virtualMeetingURLTextField.text! ) == true {
                
                event?.eventVirtualMeetingURL = URL(string: virtualMeetingURLTextField.text!)
            }
            else{
                UserMessagingController.alertUser(viewController: self, title: "Error creating event", message: "There was an issue with your virtual meeting URL. Try entering it again. Make sure to include http:// or https:// before the URL.")
                return
            }
        }
        
        event?.eventOriginatorID = AuthenticationController.user?.uid
        
        if isNewEvent {
            EventsController.createNewEvent(event!)
        }
        else{
            var eventsArray = Array<EAEvent>()
            eventsArray.append(event!)
            
            EventsController.editEvent(event: event!) { (isSuccessful) in
                if( isSuccessful ){
                    let alertController = UIAlertController(title: "Updated", message: "Successfully updated your event.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alertAction) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
                else {
                    let alertController = UIAlertController(title: "Failed", message: "Something went wrong updating your event. Ensure you have network connectivity and all fields are valid.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alertAction) in
                       print("Update event failed.")
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
