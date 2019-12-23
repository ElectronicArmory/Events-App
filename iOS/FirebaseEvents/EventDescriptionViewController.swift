//
//  EventDescriptionViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

class EventDescriptionViewController: UIViewController {

    @IBOutlet weak var profileImageView: EAImageView!
    @IBOutlet weak var marketLabel: UILabel!
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    
    var event:EAEvent?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard event != nil else {
            return
        }
        
        navigationController?.isNavigationBarHidden = true
        marketLabel.text = MarketController.currentMarket
        
        NotificationCenter.default.addObserver(self, selector: #selector(marketUpdated), name: NSNotification.Name("MARKET_UPDATED"), object: nil)
        
        profileImageView.sd_setImage(with: AuthenticationController.user?.photoURL, completed: nil)
        
        eventTitleLabel.text = event?.eventTopic
        eventDescriptionTextView.text = Utility.convertDatabaseString(stringToConvert: (event?.eventDescription)!)
    }
    

    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func marketUpdated(){
        marketLabel.text = MarketController.currentMarket
    }
    
    @IBAction func profileTapped(_ sender: Any) {
        let profileViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as! ProfileViewController
        profileViewController.user = AuthenticationController.user
        
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
