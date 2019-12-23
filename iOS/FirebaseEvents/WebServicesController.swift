//
//  WebServicesController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

class WebServicesController: NSObject {

    static let WEB_HOST:String = "https://us-central1-bsu-example.cloudfunctions.net/app"
    
    static func authenticationHeader()-> [String:String]{
        return ["Authorization": "Bearer \(AuthenticationController.authorizationToken)"]
    }
}
