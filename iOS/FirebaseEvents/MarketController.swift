//
//  MarketController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseFirestore


class MarketController: NSObject {

    static var marketControllerInstance:MarketController?
    static var currentMarket:String?
    
    static let USERDEFAULT_KEY = "MARKET"
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    static func startMonitoringForMarketChanges(){
        if( marketControllerInstance == nil ){
            currentMarket = UserDefaults.standard.string(forKey: MarketController.USERDEFAULT_KEY)
            if currentMarket == nil {
                currentMarket = "Boise"
            }
            marketControllerInstance = MarketController()
        }
        
        NotificationCenter.default.addObserver(marketControllerInstance!, selector: #selector(updateMarketLocation), name: NSNotification.Name("LOCATION_UPDATED"), object: nil)
    }
    
    
    static func stopMonitoringForMarketChanges(){
        NotificationCenter.default.removeObserver(marketControllerInstance!)
    }
    
    
    @objc
    func updateMarketLocation(){
        
        let currentCoordinates = LocationController.currentLocation?.coordinate
        
        guard AuthenticationController.authorizationToken != "" else {
            return
        }
        
        let headers:HTTPHeaders = ["Authorization": "Bearer \(AuthenticationController.authorizationToken)",
            "latitude": "\((currentCoordinates?.latitude)!)",
            "longitude": "\((currentCoordinates?.longitude)!)"]
        
        // TODO: Put in WebServices Controller
        let url = URL(string: "\(WebServicesController.WEB_HOST)/location")!
        Alamofire.request(url, headers: headers).responseJSON { (response) in
            print(response)
            if( response.response?.statusCode == 200 ){
                let responseData = response.result.value as! NSDictionary
                
                let market = responseData["market"] as! String
                if MarketController.currentMarket != market {
                    MarketController.currentMarket = market
                    UserDefaults.standard.setValue(market, forKey: MarketController.USERDEFAULT_KEY)
                }
                
                // TODO: Extra sync remove
                self.syncMarket(market)
            }
            else if ( response.response?.statusCode == 403 ){
                print(403)
            }
        }
    }
    
    
    func syncMarket(_ market:String ){
        NotificationCenter.default.post(name: NSNotification.Name("MARKET_UPDATED"), object: MarketController.currentMarket)
        
        ProfileController.updateUserInfo([
            "market": market
        ])
    }
    
}
