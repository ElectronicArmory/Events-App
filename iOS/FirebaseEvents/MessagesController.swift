//
//  MessagesController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import Alamofire


class MessagesController: NSObject {

    
    static var chatUsersArray:Array = Array<EAUser>()
    static var isLoading:Bool = false
    
    
    
    static func loadChatUsers() -> Array<EAUser>{
        
        // Load users
        if( isLoading == false ){
            let headers:HTTPHeaders = WebServicesController.authenticationHeader()
            let url:URL = URL(string:"\(WebServicesController.WEB_HOST)/users/chat")!
            isLoading = true
            Alamofire.request(url, headers: headers).responseJSON { (response) in
                isLoading = false
                if( response.result.isSuccess ){
                    chatUsersArray = EAUserFactory.usersFromJSON(usersInfoArray: response.result.value as! Array<Dictionary<AnyHashable, Any>>)
                    
                    NotificationCenter.default.post(Notification(name: Notification.Name("CHAT_USERS_LOADED"), object: self.chatUsersArray, userInfo: nil))
                }
                else{
                    print("error: \(response)")
                    
                    chatUsersArray = EAUserFactory.usersFromJSON(usersInfoArray: Array<Dictionary<AnyHashable, Any>>())
                    
                    NotificationCenter.default.post(Notification(name: Notification.Name("CHAT_USERS_LOADED"), object: self.chatUsersArray, userInfo: nil))
                }
            }
        }
        
        return chatUsersArray
    }
}
