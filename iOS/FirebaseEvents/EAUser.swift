//
//  EAUser.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import Foundation


class EAUser: NSObject {
    // Firebase user properties
    var uid:String? = nil
    var firstName:String? = nil
    var lastName:String? = nil
    var email:String? = nil
    var photoURL:URL? = nil
    var displayName:String? = nil
    var phoneNumber:String? = nil
    
    
    // Custom properties
    var occupation:String? = nil
    var company:String? = nil
    var about:String? = nil
    var address:EALocation? = nil
    

    static let kUID:String = "uid"
    static let kFirstName:String = "first_name"
    static let kLastName:String = "last_name"
    static let kEmail:String = "email"
    static let kPhotoURL:String = "photoURL"
    static let kDisplayName:String = "displayName"
    static let kPhoneNumber:String = "phoneNumber"
    
    static let kOccupation:String = "occupation"
    static let kCompany:String = "company"
    static let kAbout:String = "about"
    static let kAddress:String = "address"
    
}
