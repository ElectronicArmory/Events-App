//
//  ProfileViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Alamofire
import MessageUI


class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var networkButton: UIButton!
    
    @IBOutlet weak var profileActionsView: UIView!
    @IBOutlet weak var profileActionsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var marketLabel: UILabel!
    
    var profileUID:String?
    var user:EAUser?
    
    
    fileprivate func hideActionsView() {
        profileActionsView.isHidden = true
        profileActionsViewHeightConstraint.constant = 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        
        marketLabel.text = MarketController.currentMarket
        
        NotificationCenter.default.addObserver(self, selector: #selector(marketUpdated), name: NSNotification.Name("MARKET_UPDATED"), object: nil)
        
        // Self Profile
        if( profileUID == nil ){
            user = AuthenticationController.user
            logoutButton.isHidden = false
            hideActionsView()
            
            if user?.firstName?.isEmpty == false {
                user?.displayName = "\((user?.firstName)!) \((user?.lastName)!)"
            }
            else if user?.displayName == nil || (user?.displayName?.isEmpty)! {
                let firstName:String = UserDefaults.standard.object(forKey: "KEY_FIRST_NAME") as? String ?? ""
                let lastName:String = UserDefaults.standard.object(forKey: "KEY_LAST_NAME") as? String ?? ""
                
                if firstName.isEmpty == false {
                    ProfileController.updateUserInfo(["first_name": firstName, "last_name": lastName])
                    
                    user?.displayName = "\(firstName) \(lastName)"
                }
            }
        }
        // Other profile
        else{
            // TODO: Remove when adding messaging or networking
            hideActionsView()
            //TODO: check for nil so we don't double load this.
            user = nil
            
            Firestore.firestore().collection("users").document(profileUID!).getDocument { (snapshot, error) in

                self.user = EAUserFactory.userMetaData(userInfo: snapshot!)
                Alamofire.request(URL(string: "https://us-central1-bsu-example.cloudfunctions.net/app/users/\(self.profileUID!)/metadata")!, headers: WebServicesController.authenticationHeader()).responseJSON(completionHandler: { (response) in
                    
                    if let jsonResponse = response.result.value as? NSDictionary {
                        let photoURL:String = jsonResponse["photoURL"] as! String
                        self.user?.photoURL = URL(string: photoURL)
                        self.user?.displayName = jsonResponse["displayName"] as? String
                        self.user?.firstName = jsonResponse["first_name"] as? String
                        self.user?.lastName = jsonResponse["last_name"] as? String
                        self.user?.phoneNumber = jsonResponse["phoneNumber"] as? String
                        
                        // TODO: get first and last name
                    }
                    self.tableView.reloadData()
                })
                
                let db = Firestore.firestore()
                db.collection("networks").whereField("networked_uid", isEqualTo: self.profileUID!).getDocuments(completion: { (snapshot, error) in
                    if( error != nil ){
                        print(error!)
                        return
                    }
                    
                    self.networkButton.isHidden = false
                    
                    if( (snapshot?.documents.count)! > 0 ){
                        self.networkButton.setTitle("Remove from network", for: .normal)
                        self.networkButton.tag = 1
                    }
                    else{
                        self.networkButton.setTitle("Add to network", for: .normal)
                        self.networkButton.tag = 0
                    }
                })
                
            }
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    
    @objc
    func marketUpdated(){
        marketLabel.text = MarketController.currentMarket
        EventsController.updateEvents { (events) in
            self.tableView.reloadData()
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            
            AuthenticationController.authorizationToken = ""
        }
        catch {
            print("could not log out")
        }
    
        self.navigationController?.popToRootViewController(animated: false)
        
        RootViewController.loadLoginView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if user == nil {
            return 0
        }
        else{
            return 10
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:ProfileTableViewCell
        
        switch indexPath.row {
        // Profile Image
        case 0:
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "ProfilePhotoCell") as! ImageTableViewCell
            imageCell.fullImageView?.sd_setImage(with: user?.photoURL, completed: nil)
            if AuthenticationController.user?.uid != user?.uid {
                imageCell.selectionStyle = .none
            }
            return imageCell
        // Name
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileNameCell", for: indexPath) as! ProfileTableViewCell
            cell.mainLabel.text = user?.displayName
            if user?.displayName != nil && user?.displayName?.isEmpty != true {
                cell.mainLabel?.text = user?.displayName
            }
            else if( user?.uid == AuthenticationController.user?.uid ){
                cell.mainLabel?.text = "Set Name"
            }
            else{
                cell.mainLabel?.text = ""
            }
            
            // TODO: copy name to clipboard
            if AuthenticationController.user?.uid != user?.uid {
                cell.selectionStyle = .none
            }
        // Occupation
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoCell", for: indexPath) as! ProfileTableViewCell
            
            if AuthenticationController.user?.uid != user?.uid {
                cell.selectionStyle = .none
            }
            
            if user?.occupation != nil {
                cell.mainLabel?.text = user?.occupation
            }
            else if( user?.uid == AuthenticationController.user?.uid ){
                cell.mainLabel?.text = "Set Occupation"
            }
            else{
                cell.mainLabel?.text = ""
            }
        // Company
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoCell", for: indexPath) as! ProfileTableViewCell

            if AuthenticationController.user?.uid != user?.uid {
                cell.selectionStyle = .none
            }
            
            if user?.company != nil && user?.company?.isEmpty != true {
                cell.mainLabel?.text = user?.company
                cell.mainLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
                cell.mainLabel.textColor = UIColor.black
            }
            else if( user?.uid == AuthenticationController.user?.uid ){
                cell.mainLabel?.text = "Set Company"
                cell.mainLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
                cell.mainLabel.textColor = UIColor(red: 166.0/255.0, green: 166.0/255.5, blue: 166.0/255.0, alpha: 1.0)
            }
            else{
                cell.mainLabel?.text = ""
                if AuthenticationController.user?.uid != user?.uid {
                    cell.selectionStyle = .none
                }
            }
        // Contact Info Title
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTitleCell", for: indexPath) as! ProfileTableViewCell
            cell.mainLabel?.text = "Contact Info"
            cell.selectionStyle = .none
        // Phone number
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoCell", for: indexPath) as! ProfileTableViewCell
            cell.mainLabel?.text = user?.phoneNumber
        // Email Address
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoCell", for: indexPath) as! ProfileTableViewCell
            if user?.email != nil && user?.email?.isEmpty != true{
                cell.mainLabel?.text = user?.email
                cell.mainLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
                cell.mainLabel.textColor = UIColor.black
            }
            else if( user?.uid == AuthenticationController.user?.uid ){
                cell.mainLabel?.text = "Set Email Address"
                cell.mainLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
                cell.mainLabel.textColor = UIColor(red: 166.0/255.0, green: 166.0/255.5, blue: 166.0/255.0, alpha: 1.0)
            }
            else{
                cell.mainLabel?.text = ""
                cell.selectionStyle = .none
            }
        // Address
        case 7:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoCell", for: indexPath) as! ProfileTableViewCell
            if( user?.address?.addressOne == nil || user?.address?.addressOne?.isEmpty == true ){
                if( user?.uid == AuthenticationController.user?.uid ){
                    cell.mainLabel?.text = "Set Address"
                    cell.mainLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
                    cell.mainLabel.textColor = UIColor(red: 166.0/255.0, green: 166.0/255.5, blue: 166.0/255.0, alpha: 1.0)
                }
                cell.mainLabel.text = ""
            }
            else{
                cell.mainLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
                cell.mainLabel.textColor = UIColor.black
                cell.mainLabel.text = "\((user?.address?.addressOne ?? "")) \((user?.address?.addressTwo ?? "")!)\n\(user?.address?.city ?? "??"), \(user?.address?.state ?? "??") \(user?.address?.zip ?? "??")"
            }
            
            
            cell.selectionStyle = .none
        // About label
        case 8:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTitleCell", for: indexPath) as! ProfileTableViewCell
            if user?.about != nil && user?.about?.isEmpty != true {
                cell.mainLabel?.text = "About Me"
            }
            else{
                cell.mainLabel?.text = ""
                cell.selectionStyle = .none
            }
        // Abbout
        case 9:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoCell", for: indexPath) as! ProfileTableViewCell
            
            if AuthenticationController.user?.uid != user?.uid {
                cell.selectionStyle = .none
            }
            
            if user?.about != "" && user?.about != nil {
                cell.mainLabel?.text = user?.about
                cell.mainLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
                cell.mainLabel.textColor = UIColor.black
            }
            else if user?.uid == AuthenticationController.user?.uid{
                cell.mainLabel.text = "Edit About"
                cell.mainLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
                cell.mainLabel.textColor = UIColor(red: 166.0/255.0, green: 166.0/255.5, blue: 166.0/255.0, alpha: 1.0)
            }
            else if (user?.about == nil || (user?.about?.isEmpty)!) {
                cell.mainLabel?.text = ""
                cell.selectionStyle = .none
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoCell", for: indexPath) as! ProfileTableViewCell
            cell.mainLabel?.text = "Default"
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if( user?.uid == AuthenticationController.user?.uid ){
        
            if( indexPath.row == 0 ){
                let profilePhotoViewController:CaptureProfilePhotoViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: CaptureProfilePhotoViewController.self)) as! CaptureProfilePhotoViewController
                navigationController?.pushViewController(profilePhotoViewController, animated: true)
                return
            }
            
            
            let profileEditViewController:ProfileEditViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileEditViewController.self)) as! ProfileEditViewController
            
            switch indexPath.row {
            
            case 1:
                profileEditViewController.displayTitle = "Name"
                profileEditViewController.oldValue = user?.firstName
                profileEditViewController.oldValue2 = user?.lastName
            case 2:
                profileEditViewController.displayTitle = "Occupation"
                profileEditViewController.oldValue = user?.occupation
            case 3:
                profileEditViewController.displayTitle = "Company"
                profileEditViewController.oldValue = user?.company
            case 4, 5:
                return
            case 6:
                profileEditViewController.displayTitle = "E-mail"
                profileEditViewController.oldValue = user?.email
            case 7:
                profileEditViewController.displayTitle = "Address"
                profileEditViewController.location = user?.address
            case 8:
                return
            case 9:
                profileEditViewController.displayTitle = "About"
                profileEditViewController.oldValue = user?.about
            default:
                tableView.deselectRow(at: indexPath, animated: false)
            }
            
            navigationController?.pushViewController(profileEditViewController, animated: true)
        }
        else{
            switch indexPath.row {
                
            case 5:
                if let url = URL(string: "tel://\((user?.phoneNumber)!)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            case 6:
                guard user?.email != nil else {
                    return
                }
                let emailTitle = "Let's meet up!"
                let messageBody = ""
                let toRecipents = [(user?.email)!]
                let mailViewController: MFMailComposeViewController = MFMailComposeViewController()
                mailViewController.mailComposeDelegate = self
                mailViewController.setSubject(emailTitle)
                mailViewController.setMessageBody(messageBody, isHTML: false)
                mailViewController.setToRecipients(toRecipents)
                
                self.present(mailViewController, animated: true, completion: nil)
            default:
                print("not implemented")
            }
        }
    }


    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func messageUserTapped(_ sender: Any) {
        let chatViewController:ChatViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: ChatViewController.self)) as! ChatViewController
        
        chatViewController.remoteUser = user
        
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    
    @IBAction func addToNetworkTapped(_ sender: Any) {
        if( networkButton.tag == 0 ){
            UserMessagingController.startLoadingHUD(message: "Adding to network...")
            
            NetworkingController.addToNetwork(userID: (user?.uid)!, completion: { responseCode in
                UserMessagingController.stopLoadingHUD()
                
                if responseCode == 200 {
                    self.networkButton.setTitle("Remove from network", for: .normal)
                    self.networkButton.tag = 1
                }
                else if responseCode == 406 {
                    let alertController = UIAlertController(title: "Network", message: "This person is already in your network.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    self.networkButton.tag = 1
                    self.networkButton.setTitle("Remove from network", for: .normal)
                }
                else{
                    let alertController = UIAlertController(title: "Network", message: "You've reached the max network. Sign up for a premium account?", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Sign up", style: .default, handler: { (action) in
                        print("coming soon")
                    }))
                    alertController.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        else if( networkButton.tag == 1 ){
            UserMessagingController.startLoadingHUD(message: "Removing from network...")
            
            NetworkingController.removeFromNetwork(userID: (user?.uid)!, completion: { isSuccess in
                UserMessagingController.stopLoadingHUD()
                
                if isSuccess == true {
                    self.networkButton.setTitle("Add to network", for: .normal)
                    self.networkButton.tag = 0
                }
                else{
                    print("Something went wrong.")
                }
            })
        }
    }
    
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func profileTapped(_ sender: Any) {
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
