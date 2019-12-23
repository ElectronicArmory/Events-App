//
//  MessagesViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import Alamofire


class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.loadNewUsers), name: NSNotification.Name("CHAT_USERS_LOADED"), object: nil)
        _ = MessagesController.loadChatUsers()
        
        UserMessagingController.startLoadingHUD(message: "Loading...")
        
        self.navigationController?.navigationBar.isHidden = true
    }

    
    @objc
    func loadNewUsers(){
        UserMessagingController.stopLoadingHUD()
        self.tableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessagesController.chatUsersArray.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let chatViewController:ChatViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ChatViewController.self)) as! ChatViewController
        chatViewController.remoteUser = MessagesController.chatUsersArray[indexPath.row]
        
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ChatUserCell")! as! UserMessageTableViewCell
        
        let currentUser:EAUser = MessagesController.chatUsersArray[indexPath.row]
        if( currentUser.displayName != nil ){
            cell.displayNameLabel?.text = currentUser.displayName! // TODO: display name nil
        }
        cell.profileImageView?.sd_setImage(with: currentUser.photoURL, placeholderImage: UIImage(named: "user-image-default"))
        
        let url = URL(string: "\(WebServicesController.WEB_HOST)/users/chat/lastmessage")
        var headers:HTTPHeaders = WebServicesController.authenticationHeader()
        headers["friend_uid"] = currentUser.uid
        Alamofire.request(url!, headers: headers).responseJSON { (response) in
            
            if (response.result.isSuccess == true ){
                
                if(response.result.value) != nil{
                    
                    // TODO: check for 404 in dataInfo
                    if let dataInfo = response.result.value as? NSDictionary {
                        cell.lastChatMessageLabel.text = dataInfo["message"] as? String
                        
                        if let messageTimestamp = dataInfo["timestamp"] as? String {
                        
                            let dateParser = DateFormatter()
                            dateParser.locale = Locale(identifier: "en_US_POSIX")
                            dateParser.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZZZZZ"
                            dateParser.timeZone = TimeZone(secondsFromGMT: 0)
                            
                            let messageDate = dateParser.date(from: messageTimestamp)
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = .short
                            
                            cell.timeLabel.text = dateFormatter.string(from: messageDate!)
                            
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
