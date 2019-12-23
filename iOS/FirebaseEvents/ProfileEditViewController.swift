//
//  ProfileEditViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseFirestore


class ProfileEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    

    @IBOutlet weak var displayLabel: UILabel!
    var displayTitle:String?
    
    @IBOutlet weak var newValueTextField: UITextField!
    var oldValue:String?
    
    @IBOutlet weak var lastNameTextField: UITextField!
    var oldValue2:String?
    
    @IBOutlet weak var tableView: UITableView!
    var occupationsArray:[QueryDocumentSnapshot] = [QueryDocumentSnapshot]()
    
    @IBOutlet weak var saveButton: EAButton!
    
    @IBOutlet weak var valueTextView: UITextView!
    
    @IBOutlet weak var locationView: UIView!
    var location:EALocation? = nil
    
    var selectedStateIndex:Int = -1
    
    @IBOutlet weak var addressOne: EATextField!
    @IBOutlet weak var addressTwo: EATextField!
    @IBOutlet weak var cityTextField: EATextField!
    @IBOutlet weak var stateTextField: EATextField!
    @IBOutlet weak var zipTextField: EATextField!
    
    
    let statesArray = [
        ["Alabama", "AL"],
        ["Alaska", "AK"],
        ["Arizona", "AZ"],
        ["Arkansas", "AR"],
        ["California", "CA"],
        ["Colorado", "CO"],
        ["Connecticut", "CT"],
        ["Delaware", "DE"],
        ["Florida", "FL"],
        ["Georgia", "GA"],
        ["Hawaii", "HI"],
        ["Idaho", "ID"],
        ["Illinois", "IL"],
        ["Indiana", "IN"],
        ["Iowa", "IA"],
        ["Kansas", "KS"],
        ["Kentucky", "KY"],
        ["Louisiana", "LA"],
        ["Maine", "ME"],
        ["Maryland", "MD"],
        ["Massachusetts", "MA"],
        ["Michigan", "MI"],
        ["Minnesota", "MN"],
        ["Mississippi", "MS"],
        ["Missouri", "MO"],
        ["Montana", "MT"],
        ["Nebraska", "NE"],
        ["Nevada", "NV"],
        ["New Hampshire", "NH"],
        ["New Jersey", "NJ"],
        ["New Mexico", "NM"],
        ["New York", "NY"],
        ["North Carolina", "NC"],
        ["North Dakota", "ND"],
        ["Ohio", "OH"],
        ["Oklahoma", "OK"],
        ["Oregon", "OR"],
        ["Pennsylvania", "PA"],
        ["Rhode Island", "RI"],
        ["South Carolina", "SC"],
        ["South Dakota", "SD"],
        ["Tennessee", "TN"],
        ["Texas", "TX"],
        ["Utah", "UT"],
        ["Vermont", "VT"],
        ["Virginia", "VA"],
        ["Washington", "WA"],
        ["West Virginia", "WV"],
        ["Wisconsin", "WI"],
        ["Wyoming", "WY"]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if( displayTitle != nil ){
            displayLabel.text = displayTitle!
        }
        
        if( displayTitle == "Occupation"){
            tableView.isHidden = false
            newValueTextField.isHidden = true
            lastNameTextField.isHidden = true
            
            saveButton.isHidden = true
            
            let db = Firestore.firestore()
            db.collection("occupations").getDocuments { (snapshot, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                self.occupationsArray = (snapshot?.documents)!
                self.tableView.reloadData()
            }
        }
        else if displayTitle == "About" {
            valueTextView.isHidden = false
            valueTextView.text = oldValue
        }
        else if displayTitle == "Address" {
            locationView.isHidden = false
            setupStateField()
        }
        else if displayTitle == "Name" {
            
            lastNameTextField.isHidden = false
            
            newValueTextField.placeholder = "First Name"
            if( oldValue != nil ){
                newValueTextField.text = oldValue!
            }
            if( oldValue2 != nil ){
                lastNameTextField.placeholder = "Last Name"
                lastNameTextField.text = oldValue2
            }
        }
        else{
            tableView.isHidden = true
            newValueTextField.isHidden = false
            saveButton.isHidden = false
            
            if( oldValue != nil ){
                newValueTextField.text = oldValue!
            }
            
            newValueTextField.placeholder = "Set your \(displayTitle!)"
        }
    }
    
    
    
    func setupStateField(){
        let picker:UIPickerView = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        
        //        picker.addTarget(self, action: #selector(updateSelectedState), for: .valueChanged)
        //        picker.
        stateTextField.inputView = picker
        
        addressOne.text = location?.addressOne
        addressTwo.text = location?.addressTwo
        cityTextField.text = location?.city
        stateTextField.text = location?.state
        zipTextField.text = location?.zip
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statesArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStateIndex = row
        stateTextField.text = statesArray[row][1]
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statesArray[row][0]
    }
    
    
    
    @IBAction func saveTapped(){
        print("saved")
        
        let newValue:String = newValueTextField.text!
        let newValue2:String = lastNameTextField.text!
        
        switch displayTitle {
        case "Name":
            AuthenticationController.user?.displayName = "\(newValue) \(newValue2)"
            AuthenticationController.user?.firstName = newValue
            AuthenticationController.user?.lastName = newValue2
            
            ProfileController.updateUserDisplayName(newName: "\(newValue) \(newValue2)")
            ProfileController.updateUserInfo(["first_name": newValue, "last_name": newValue2])
        case "Company":
            AuthenticationController.user?.company = newValue
            ProfileController.updateUserInfo(["company": newValue])
        case "About":
            let newAboutValue = valueTextView.text!
            AuthenticationController.user?.about = newAboutValue
            ProfileController.updateUserInfo(["about": newAboutValue])
        case "Address":
            AuthenticationController.user?.address?.addressOne = addressOne.text
            AuthenticationController.user?.address?.addressTwo = addressTwo.text
            AuthenticationController.user?.address?.city = cityTextField.text
            if selectedStateIndex > -1 {
                AuthenticationController.user?.address?.state = statesArray[selectedStateIndex][1]
            }
            else{
                AuthenticationController.user?.address?.state = ""
            }
            AuthenticationController.user?.address?.zip = zipTextField.text
            ProfileController.updateUserAddress()
        case "E-mail":
            AuthenticationController.user?.email = newValue
            ProfileController.updateUserInfo(["email": newValue])
        default:
            print("default: \(displayTitle!)")
        }
        navigationController?.popViewController(animated: true)
    }

    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return occupationsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "OccupationCell")!
        
        let currentOccupation = self.occupationsArray[indexPath.row]
        
        cell.textLabel?.text = currentOccupation.documentID
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let newOccupation:String = occupationsArray[indexPath.row].documentID
        AuthenticationController.user?.occupation = newOccupation
        ProfileController.updateUserInfo(["occupation":newOccupation])
        navigationController?.popViewController(animated: true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
