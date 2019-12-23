//
//  NetworkingController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

import FirebaseFirestore
import Alamofire


class NetworkingController: NSObject {

    static let db = Firestore.firestore()
    
    static var lastRecommendedCall:Date?
    
    static var recommendedUsers:Array = Array<EAUser>()
    
    
    static func readNetworks(){
        db.collection("networks").getDocuments { (snapshot, error) in
            if( error != nil ){
                
                let errorNS = error! as NSError
                print(errorNS)
                return
            }
            
            let documents = snapshot?.documents
            let count = documents?.count
            print(count!)
            for document in documents!{
                print(document)
            }
        }
    }
    
    
    static func addToNetwork(userID:String, completion: @escaping (Int) -> Void){
        
        Alamofire.request(WebServicesController.WEB_HOST + "/network/" + userID, method: .post, headers: WebServicesController.authenticationHeader()).responseJSON { (response) in
            
            print(response)
            if( response.result.isSuccess == true ){
                if (response.response?.statusCode == 200) {
                    completion(200)
                }
                else{
                    completion((response.response?.statusCode)!)
                }
            }
            else{
                completion((response.response?.statusCode)!)
            }
        }
    }
    
    
    static func removeFromNetwork(userID:String, completion: @escaping (Bool) -> Void){
    
        Alamofire.request(WebServicesController.WEB_HOST + "/network/" + userID, method: .delete, headers: WebServicesController.authenticationHeader()).responseJSON { (response) in
            
            print(response)
            if( response.result.isSuccess == true ){
                if (response.response?.statusCode == 200) {
                    completion(true)
                }
                else{
                    completion(false)
                }
            }
            else{
                completion(false)
            }
        }
    }
    
    
    
    static func recommendedPeople(completion: @escaping(Bool) -> Void ){
        
        let timeSinceLastCall = lastRecommendedCall?.timeIntervalSinceNow
        // TODO: Constant for time interval
        if( timeSinceLastCall == nil || (timeSinceLastCall?.isLess(than: -600.0))! ){
            lastRecommendedCall = Date()
            
            var headers:HTTPHeaders = WebServicesController.authenticationHeader()
            headers["market"] = MarketController.currentMarket!
            
            Alamofire.request(WebServicesController.WEB_HOST + "/users/recommended?limit=50", headers: headers).responseJSON { (response) in
                print(response)
                if( response.result.isSuccess == true ){
                    if (response.response?.statusCode == 200) {

                        for currentUser in response.value as! Array<Dictionary<AnyHashable, Any>> {
                            
                            let newUser = EAUser()
                            newUser.uid = currentUser["uid"] as? String
                            
                            if let photoURL:String = currentUser["photoURL"] as? String {
                                newUser.photoURL = URL(string: photoURL)
                            }
                            
                            if let displayName = currentUser["displayName"] {
                                newUser.displayName = displayName as? String
                            }
                            else{
                                newUser.displayName = ""
                            }
                            
                            if let occupation = currentUser["occupation"] {
                                newUser.occupation = occupation as? String
                            }
                            else{
                                newUser.occupation = ""
                            }
                            
                            if newUser.displayName != "" {
                                NetworkingController.recommendedUsers.append(newUser)
                            }
                        }
                        completion(true)
                    }
                    else{
                        completion(false)
                    }
                }
                else{
                    completion(false)
                }
            }
        }
        else{
            completion(true)
        }
    }

}

