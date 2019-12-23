//
//  PeopleViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Alamofire


class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    let db:Firestore = Firestore.firestore()
    
    var network:[QueryDocumentSnapshot] = [QueryDocumentSnapshot]()

    var event:EAEvent? = nil
    
    public
    var usersToList:[EAUser]? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        if let userProfileLocation:URL = AuthenticationController.user?.photoURL {
            let placeholderImage:UIImage? = UIImage(named: "placeholder.jpg")
            if placeholderImage != nil{
                profileImageView.sd_setImage(with: userProfileLocation, placeholderImage: placeholderImage)
                
                profileImageView.layer.masksToBounds = true
                profileImageView.layer.cornerRadius = profileImageView.frame.height/2
            }
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if( usersToList == nil ){
            UserMessagingController.startLoadingHUD(message: "Loading...")
            NetworkingController.recommendedPeople { (success) in
                UserMessagingController.stopLoadingHUD()
                if( success ){
                    self.usersToList = NetworkingController.recommendedUsers
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func showProfile(_ sender: Any) {
        let profileViewController:ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as! ProfileViewController
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersToList!.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PeopleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell")! as! PeopleTableViewCell
        
        let index = indexPath.row
        let currentPerson = usersToList![index]
        
        cell.nameLabel.text = currentPerson.displayName
        cell.occupationLabel.text = currentPerson.occupation
        
        cell.profileImageView.sd_setImage(with: currentPerson.photoURL, completed: nil)
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let profileViewController:ProfileViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as! ProfileViewController
        
        let currentPerson = usersToList![indexPath.row]
        
        profileViewController.profileUID = currentPerson.uid
        
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
