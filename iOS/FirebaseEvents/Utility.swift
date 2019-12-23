//
//  Utility.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

class Utility: NSObject {

    static func convertDatabaseString(stringToConvert:String)->String{
        return stringToConvert.replacingOccurrences(of: "\\n", with: "\n")
        
    }
    
    static func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
}
