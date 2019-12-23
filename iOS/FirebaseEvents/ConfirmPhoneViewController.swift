//
//  ConfirmPhoneViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseAuth



class ConfirmPhoneViewController: UIViewController {

    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var submitButton: EAButton!
    
    var isNewAccount = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeTextField.becomeFirstResponder()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        codeTextField.resignFirstResponder()
        
        if let verificationCode:String = codeTextField.text, let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") {
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: verificationCode)
            
            
            UserMessagingController.startLoadingHUD(message: "Confirming your login code...")
            
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                
                UserMessagingController.stopLoadingHUD()
                
                if let error = error {
                    // ...
                    
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        
                        var alert:UIAlertController
                        print(error)
                        
                        switch errCode {
                        case .invalidVerificationCode:
                            alert = UIAlertController(title: "Sign in Error", message: "Invalid verification code", preferredStyle: .alert)
                        case .missingVerificationCode:
                            alert = UIAlertController(title: "Sign in Error", message: "Missing verification code", preferredStyle: .alert)
                        default:
                            alert = UIAlertController(title: "Sign in Error", message: "An error has occurred. Please retry later.", preferredStyle: .alert)
                        }
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                // User is signed in
                // ...
                
                if( self.isNewAccount == true && authResult?.user.photoURL == nil){
                    let firstName = UserDefaults.standard.object(forKey: "KEY_FIRST_NAME") ?? ""
                    let lastName = UserDefaults.standard.object(forKey: "KEY_LAST_NAME") ?? ""
                    
                    ProfileController.updateUserDisplayName(newName: "\(firstName) \(lastName)")
                    ProfileController.updateUserInfo(["first_name": firstName, "last_name": lastName])
                    
                    let captureProfilePhotoViewController:CaptureProfilePhotoViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: CaptureProfilePhotoViewController.self)) as! CaptureProfilePhotoViewController
                    captureProfilePhotoViewController.isRequired = true
                    self.navigationController?.pushViewController(captureProfilePhotoViewController, animated: true)
                }
                else{
                    RootViewController.loadTodayViewController()
                }
                authResult?.user.getIDToken(completion: { (idToken, error) in
                    if( error == nil ){
                        print("Token: \(idToken!)")
                        AuthenticationController.authorizationToken = idToken!
                    }
                })
                
            }
        }
    }
    
    
    
    @IBAction func backTapped(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
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
