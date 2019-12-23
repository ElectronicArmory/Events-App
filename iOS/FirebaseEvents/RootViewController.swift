//
//  RootViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseAuth
import Reachability


class RootViewController: UIViewController {

    static var isInitialLoad:Bool = true
    static var initialViewController:UIViewController? = nil
    static var todayViewController:UINavigationController? = nil
    static var tabBarController: UITabBarController? = nil
    static var rootViewControllerInstance:RootViewController? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RootViewController.tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
        
        UITabBar.appearance().tintColor = UIColor(red: 166.0/255.0, green: 166.0/255.5, blue: 166.0/255.0, alpha: 1.0)
        
        RootViewController.todayViewController = self.storyboard?.instantiateViewController(withIdentifier: "TodayViewControllerNav") as? UINavigationController
        RootViewController.initialViewController = RootViewController.tabBarController
        RootViewController.rootViewControllerInstance = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkConnected), name: Notification.Name("REACHABILITY_CONNECTED"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUIBecauseUserWasUpdate), name: Notification.Name("USER_UPDATED"), object: nil)
    }
    
    @objc
    func updateUIBecauseUserWasUpdate(notification:Notification){
//        notification.object as
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if( RootViewController.isInitialLoad == true ){
            RootViewController.isInitialLoad = false
            
//            if( Reachability. NetworkReachability.isNetworkReachableAny() == true ){
                initializeView()
//            }
//            else{
//                RootViewController.isInitialLoad = true
//            }
        }
    }
    
    
    @objc
    func networkConnected(){
        if( RootViewController.isInitialLoad == true ){
            RootViewController.isInitialLoad = false
            initializeView()
        }
    }
    
    
    func initializeView(){
        if let currentUser = Auth.auth().currentUser {
            
            currentUser.getIDToken(completion: { (idToken, error) in
                if( error == nil ){
                    print("Token: \(idToken!)")
                    AuthenticationController.authorizationToken = idToken!
                    
                    if( error != nil ){
                        print(error!.localizedDescription)
                        UserMessagingController.alertUser(viewController: RootViewController.initialViewController!, title: "You have been logged out", message: (error?.localizedDescription)!)
                        RootViewController.loadLoginView()
                    }
                    
                    if( idToken != nil ){
                        RootViewController.loadTodayViewController()
                    }
                }
                else{
                    print(error!)
                }
            })
        }
        else{
            RootViewController.loadLoginView()
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    static func loadLoginView()
    {
        RootViewController.initialViewController = RootViewController.rootViewControllerInstance?.storyboard!.instantiateViewController(withIdentifier: "LoginNavigation")
        UIApplication.shared.keyWindow?.rootViewController = RootViewController.initialViewController!
    }
    
    
    static func loadTodayViewController(){
        UIApplication.shared.keyWindow?.rootViewController = tabBarController
    }

}
