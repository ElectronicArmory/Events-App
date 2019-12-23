//
//  EventLocationViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit


class EventLocationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    var event:EAEvent?
    
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var addressOneTextField: UITextField!
    @IBOutlet weak var addressTwoTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    var selectedStateIndex = -1
    
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

        locationNameTextField.text = event?.eventLocation?.locationName ?? ""
        addressOneTextField.text = event?.eventLocation?.addressOne ?? ""
        addressTwoTextField.text = event?.eventLocation?.addressTwo ?? ""
        cityTextField.text = event?.eventLocation?.city ?? ""
        stateTextField.text = event?.eventLocation?.state ?? ""
        zipCodeTextField.text = event?.eventLocation?.zip ?? ""
        
        setupStateField()
    }
    
    
    
    func setupStateField(){
        let picker:UIPickerView = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        
//        picker.addTarget(self, action: #selector(updateSelectedState), for: .valueChanged)
//        picker.
        stateTextField.inputView = picker
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
    
    
    
    @IBAction func updateLocationTapped(_ sender: Any) {
        
        event?.eventLocation?.locationName = locationNameTextField.text
        event?.eventLocation?.addressOne = addressOneTextField.text
        event?.eventLocation?.addressTwo = addressTwoTextField.text
        event?.eventLocation?.city = cityTextField.text
        if selectedStateIndex > -1 {
            event?.eventLocation?.state = statesArray[selectedStateIndex][1]
        }
        else{
            event?.eventLocation?.state = ""
        }
        event?.eventLocation?.zip = zipCodeTextField.text
        
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    /*
    // MARK:", "Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
