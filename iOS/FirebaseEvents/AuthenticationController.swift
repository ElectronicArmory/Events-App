//
//  AuthenticationController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore



class AuthenticationController: NSObject {
    static var user:EAUser? = nil
    
    static var handle:AuthStateDidChangeListenerHandle?
    static var authorizationToken:String = ""
    
    
    static let NOTIFICATION_UPDATED:String = "NOTIFICATION_UPDATED"
    
    static func startAuthenticationMonitoring(){
        if( user == nil ){
            user = EAUser()
        }
        handle = Auth.auth().addStateDidChangeListener { (auth, firebaseUser) in
            // ...
            if let authenticatedUser = firebaseUser {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                user?.uid = authenticatedUser.uid
                user?.email = authenticatedUser.email
                user?.photoURL = authenticatedUser.photoURL
                user?.displayName = authenticatedUser.displayName
                user?.phoneNumber = authenticatedUser.phoneNumber
                
                NotificationCenter.default.post(Notification(name: Notification.Name("USER_UPDATED")))
                
                let db = Firestore.firestore()
                db.collection("users").document((user?.uid)!).getDocument() { (data, error) in
                    if (error != nil) {
                        print("Error getting documents: \(error!.localizedDescription)")
                        UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Error getting user profile", message: (error?.localizedDescription)!)
                    }
                    else {
                        if let document = data, (data?.exists)! {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            
                            
                            let documentData = document.data()
                            
                            // TODO: User factory
//                            EAUserFactory.userMetaData(userInfo: documentData)
                            user?.firstName = documentData?["first_name"] as? String
                            user?.lastName = documentData?["last_name"] as? String
                            user?.occupation = documentData?["occupation"] as? String
                            user?.company = documentData?["company"] as? String
                            user?.about = documentData?["about"] as? String
                            user?.email = documentData?["email"] as? String
                            
                            user?.address = EALocation()
                            
                            if documentData?["address"] != nil {
                                let addressData = documentData?["address"] as! [AnyHashable: Any]
                                
                                user?.address?.addressOne = addressData["address_one"] as? String
                                user?.address?.addressTwo = addressData["address_two"] as? String
                                user?.address?.city = addressData["city"] as? String
                                user?.address?.state = addressData["state"] as? String
                                user?.address?.zip = addressData["zip"] as? String
                            }
                            NotificationCenter.default.post(name: Notification.Name(NOTIFICATION_UPDATED), object: user)
                        }
                        else {
                            print("Document does not exist")
                        }
                    }
                }
            }
        }
    }
    
    
    static func stopAuthenticationMonitoring(){
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    static func verifyUserPhone(phoneNumber:String, completion: @escaping(_ verificationID:String) ->Void){
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {

                let authError = error as NSError
                print(authError)
                if(authError.code == 17042){
                    UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Phone verification error", message: "The phone number you entered wasn't a US-based phone number. Please try again.")
                }
                else if( authError.code == 17010 ){
                    UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Phone verification error", message: "An error occured while signing up. This error has been sent to our support team.")
                }
                else if( authError.code == 17042){
                    UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Phone verification error", message: "An error occured while verifying your phone number. The phone number is too short. Please try again.")
                }
                else{
                    UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Phone verification error", message: "An error occured while verifying your phone number. This error has been sent to our support team. Please try again.")
                }
                print(authError)
                Crashlytics.sharedInstance().recordError(authError)
                
                UserMessagingController.stopLoadingHUD()
                
                completion("")
                
                return
            }
            // Sign in using the verificationID and the code sent to the user
            // ...
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            
            completion(verificationID!)
        }
    }
    
    
    
    static func signOutUser(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Signout error", message: signOutError.localizedDescription)
        }

    }
}
