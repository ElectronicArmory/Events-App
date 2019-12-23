//
//  EAUserFactory.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseFirestore


class EAUserFactory: NSObject {

    static func usersFromJSON(usersInfoArray:Array<Dictionary<AnyHashable, Any>>) -> Array<EAUser>{
        
        var usersArray:Array<EAUser> = []
        
        for currentUser in usersInfoArray {
            let newUser:EAUser = EAUser()
            newUser.uid = currentUser[EAUser.kUID] as? String
            newUser.photoURL = URL(string: (currentUser[EAUser.kPhotoURL] as? String)!)
            newUser.phoneNumber = currentUser[EAUser.kPhoneNumber] as? String
            newUser.displayName = currentUser[EAUser.kDisplayName] as? String
            
            if( newUser.uid != AuthenticationController.user?.uid ){
                usersArray.append(newUser)
            }
        }
        
        return usersArray
    }
    
    
    
    static func userFromJSON(userInfo:DocumentSnapshot)->EAUser{
        let newUser:EAUser = EAUser()
        newUser.uid = userInfo.documentID
        newUser.firstName = userInfo[EAUser.kFirstName] as? String
        newUser.lastName = userInfo[EAUser.kLastName] as? String
        newUser.photoURL = URL(string: (userInfo[EAUser.kPhotoURL] as? String)!)
        newUser.phoneNumber = userInfo[EAUser.kPhoneNumber] as? String
        newUser.displayName = userInfo[EAUser.kDisplayName] as? String
        newUser.company = userInfo[EAUser.kCompany] as? String
        newUser.occupation = userInfo[EAUser.kOccupation] as? String
        newUser.email = userInfo[EAUser.kEmail] as? String
        newUser.about = userInfo[EAUser.kAbout] as? String
        
        return newUser
    }
    
    
    
    static func userFromJSON(userInfo:NSDictionary)->EAUser{
        let newUser:EAUser = EAUser()
        newUser.uid = userInfo[EAUser.kUID] as? String
        newUser.firstName = userInfo[EAUser.kFirstName] as? String
        newUser.lastName = userInfo[EAUser.kLastName] as? String
        newUser.photoURL = URL(string: (userInfo[EAUser.kPhotoURL] as? String)!)
        newUser.phoneNumber = userInfo[EAUser.kPhoneNumber] as? String
        newUser.displayName = userInfo[EAUser.kDisplayName] as? String
        newUser.company = userInfo[EAUser.kCompany] as? String
        newUser.occupation = userInfo[EAUser.kOccupation] as? String
        newUser.email = userInfo[EAUser.kEmail] as? String
        newUser.about = userInfo[EAUser.kAbout] as? String
        
        return newUser
    }
    
    
    
    static func userMetaData(userInfo:DocumentSnapshot)->EAUser{
        let newUser:EAUser = EAUser()
        newUser.uid = userInfo.documentID
        newUser.firstName = userInfo[EAUser.kFirstName] as? String
        newUser.lastName = userInfo[EAUser.kLastName] as? String
        newUser.company = userInfo[EAUser.kCompany] as? String
        newUser.occupation = userInfo[EAUser.kOccupation] as? String
        newUser.email = userInfo[EAUser.kEmail] as? String
        newUser.about = userInfo[EAUser.kAbout] as? String
        
        return newUser
    }
}

