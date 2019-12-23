//
//  ProfileController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class ProfileController: NSObject {

    static let db = Firestore.firestore()
    
    
    static let kUSERS_DATABASE = "users"
    static let kUSERS_PRIVATE_DATABASE = "users_private"
    
    struct ProfileEvents {
        static let LoginSuccessEvent:String = "LoginSuccessEvent"
        static let LoginFailureEvent:String = "LoginFailureEvent"
    }
    
    class func attemptLogin(email:String, password:String){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if( error != nil ){
                UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Login error", message: (error?.localizedDescription)!)
                NotificationCenter.default.post(name: Notification.Name(rawValue: ProfileEvents.LoginFailureEvent), object: nil)
                return
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: ProfileEvents.LoginSuccessEvent), object: nil)
        }
    }
    
    
    
    static func updateUserProfileURL(newURL:URL){
        AuthenticationController.user?.photoURL = newURL
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = newURL
        changeRequest?.commitChanges { (error) in
            if( error != nil){
                print(error!.localizedDescription)
                UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Updating profile error", message: (error?.localizedDescription)!)
            }
        }
    }
    
    
    
    static func updateUserDisplayName( newName:String ){
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = newName
        changeRequest?.commitChanges { (error) in
            if( error != nil){
                print(error!.localizedDescription)
                UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "Updating profile error", message: (error?.localizedDescription)!)
            }
        }
    }
    
    
    
    static func updateUserEmail( newEmail:String ){
        Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { (error) in
            if error == nil {
                print(error!)
            }
        })
    }
    
    static func updateUserAddress(){
        if let user:User = (Auth.auth().currentUser){
            let userID:String = user.uid
            let address:EALocation = (AuthenticationController.user?.address)!
            let addressJSON = ["address": [
                "address_one": address.addressOne ?? "",
                "address_two": address.addressTwo ?? "",
                "city": address.city ?? "",
                "state": address.state ?? "",
                "zip": address.zip ?? ""]
            ]
            db.collection(kUSERS_DATABASE).document(userID).updateData(addressJSON) { (error) in
                if( error != nil){
                    let firebaseError = error! as NSError
                    switch firebaseError.code{
                    case 5:
                        db.collection(kUSERS_DATABASE).document(userID).setData(addressJSON){(error) in
                            if(error != nil){
                                print(error!)
                            }
                        }
                    default:
                        print(firebaseError.code)
                    }
                }
            }
        }
    }
    
    
    
    static func updateUserInfo(_ newInfo:[String: Any]){
        if let user:User = (Auth.auth().currentUser){
            let userID:String = user.uid
            db.collection(kUSERS_DATABASE).document(userID).updateData(newInfo) { (error) in
                if( error != nil){
                    let firebaseError = error! as NSError
                    switch firebaseError.code{
                    case 5:
                        db.collection(kUSERS_DATABASE).document(userID).setData(newInfo){(error) in
                            if(error != nil){
                                print(error!)
                            }
                        }
                    default:
                        print(firebaseError.code)
                    }
                }
            }
        }
    }
    
    
    
    static func updateUserPrivateInfo(_ newInfo:[String: Any]){
        if let user:User = (Auth.auth().currentUser){
            let userID:String = user.uid
            db.collection(ProfileController.kUSERS_PRIVATE_DATABASE).document(userID).updateData(newInfo) { (error) in
                if( error != nil){
                    let firebaseError = error! as NSError
                    print(firebaseError)
                    switch firebaseError.code{
                    case 5:
                        db.collection(kUSERS_PRIVATE_DATABASE).document(userID).setData(newInfo){(error) in
                            if(error != nil){
                                print(error!)
                            }
                        }
                    default:
                        print(firebaseError.code)
                    }
                }
            }
        }
    }
    
    
    
    static func updateToken(fcmToken:String){
        if let user:User = (Auth.auth().currentUser){
            let userID:String = user.uid
            db.collection(ProfileController.kUSERS_PRIVATE_DATABASE)
                .document(userID).collection("tokens")
                .document(fcmToken).setData(["date": Date()]) { (error) in
                    if( error != nil ){
                        print(error!)
                    }
            }
        }
    }
}
