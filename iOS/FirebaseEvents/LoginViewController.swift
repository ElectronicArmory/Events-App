//
//  LoginViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var mobilePhoneTextField: UITextField!
    @IBOutlet weak var submitButton: EAButton!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        
        let width = CGFloat(1.0)
        
        if( firstNameTextField != nil ){
            self.navigationItem.title = "Create Account"
            
            let firstNameBorder = CALayer()
            firstNameBorder.borderColor = UIColor.gray.cgColor
            firstNameBorder.frame = CGRect(x: 0, y: firstNameTextField.frame.size.height - width, width: firstNameTextField.frame.size.width, height: firstNameTextField.frame.size.height)
            
            firstNameBorder.borderWidth = width
            firstNameTextField.layer.addSublayer(firstNameBorder)
            firstNameTextField.layer.masksToBounds = true
            
            let lastnameBorder = CALayer()
            lastnameBorder.borderColor = UIColor.gray.cgColor
            lastnameBorder.borderWidth = width
            lastnameBorder.frame = CGRect(x: 0, y: lastNameTextField.frame.size.height - width, width: lastNameTextField.frame.size.width, height: lastNameTextField.frame.size.height)
            lastNameTextField.layer.addSublayer(lastnameBorder)
            lastNameTextField.layer.masksToBounds = true
        }
        else {
            self.navigationItem.title = "Login"
        }
        
        let mobileNumberBorder = CALayer()
        mobileNumberBorder.borderColor = UIColor.gray.cgColor
        mobileNumberBorder.borderWidth = width
        mobileNumberBorder.frame = CGRect(x: 0, y: mobilePhoneTextField.frame.size.height - width, width: mobilePhoneTextField.frame.size.width, height: mobilePhoneTextField.frame.size.height)
        mobilePhoneTextField.layer.addSublayer(mobileNumberBorder)
        mobilePhoneTextField.layer.masksToBounds = true
                
        if( firstNameTextField != nil ){
            firstNameTextField.becomeFirstResponder()
        }
        else {
            mobilePhoneTextField.becomeFirstResponder()
        }
    }

    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        
        if( firstNameTextField != nil ){
            firstNameTextField.resignFirstResponder()
            lastNameTextField.resignFirstResponder()
        }
        mobilePhoneTextField.resignFirstResponder()
        
        if( firstNameTextField != nil && self.lastNameTextField != nil ){
            if( (firstNameTextField.text?.isEmpty)! || (lastNameTextField.text?.isEmpty)! ){
                let alertController:UIAlertController = UIAlertController(title: "We need more information", message: "Please enter all fields before creating your account.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
        }
        
        
        if var phoneNumber:String = mobilePhoneTextField.text {
            if phoneNumber.isEmpty == true {
                UserMessagingController.alertUser(viewController: self, title: "Phone number invalid", message: "Please enter a US-based cellphone number and try again.")
                return
            }
            
            #if IOS_SIMULATOR
            print("It's an iOS Simulator")
            #else
            UserMessagingController.startLoadingHUD(message: "Verifying your phone number...")
            #endif
            
            sender.isEnabled = false
            
            // TODO: Display and hide loading
            phoneNumber = "+1" + phoneNumber
            
            AuthenticationController.verifyUserPhone(phoneNumber: phoneNumber, completion: { verificationID in
                var confirmPhoneViewController:ConfirmPhoneViewController
                
                UserMessagingController.stopLoadingHUD()
                confirmPhoneViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ConfirmPhoneViewController.self)) as! ConfirmPhoneViewController
                
                if verificationID != "" {
                     

                    if self.firstNameTextField != nil && self.lastNameTextField != nil {
                        UserDefaults.standard.set(self.firstNameTextField.text, forKey: "KEY_FIRST_NAME")
                        UserDefaults.standard.set(self.lastNameTextField.text, forKey: "KEY_LAST_NAME")
                        confirmPhoneViewController.isNewAccount = true
                    }

               }
            self.navigationController?.pushViewController(confirmPhoneViewController, animated: true)
                
            })
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("ended")
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
