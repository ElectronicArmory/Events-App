//
//  ChatViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseFirestore


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var remoteUserProfilePhoto: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: EAButton!
    
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    var originalBottomConstraintValue:CGFloat?
    
    var remoteUser:EAUser? = nil
    var chatMessages = [QueryDocumentSnapshot]()
    var chatID:String?
    
    let db = Firestore.firestore()
    
    var keyboardIsVisible = false
    
    let placeholderText:String = "Message or arrange a meeting."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        
        if( (remoteUser?.uid)! < (AuthenticationController.user?.uid)!){
            chatID = "\((remoteUser?.uid)!)==\((AuthenticationController.user?.uid)!)"
        }
        else{
            chatID = "\((AuthenticationController.user?.uid)!)==\((remoteUser?.uid)!)"
        }
        
        messageTextView.text = placeholderText
        messageTextView.textColor = UIColor.lightGray
        messageTextView.selectedTextRange = messageTextView.textRange(from: messageTextView.beginningOfDocument, to: messageTextView.beginningOfDocument)
            
            
        self.navigationItem.title = remoteUser?.displayName
        remoteUserProfilePhoto.layer.cornerRadius = remoteUserProfilePhoto.frame.width/2
        remoteUserProfilePhoto.layer.masksToBounds = true
        remoteUserProfilePhoto.sd_setImage(with: remoteUser?.photoURL, placeholderImage: UIImage(named: "user-image-default"))
        
        if( remoteUser != nil ){
            db.collection("chats").document(self.chatID!).collection("messages").order(by: "timestamp", descending: false).addSnapshotListener({ (snapshot, error) in
                guard let document = snapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                self.chatMessages = document.documents

                self.tableView.reloadData()
                self.scrollTableViewToBottom()
            })
        }
        
        originalBottomConstraintValue = viewBottomConstraint.constant
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    
    @IBAction func goBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    @objc
    func keyboardWillShow(sender: NSNotification) {
        if( keyboardIsVisible == false ){
            keyboardIsVisible = true
            let info = sender.userInfo!
            let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
            viewBottomConstraint.constant = keyboardSize - 50 /*- bottomLayoutGuide.length*/
            
            let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            
            UIView.animate(withDuration: duration) { self.containerView.layoutIfNeeded() }
            scrollTableViewToBottom()
        }
    }
    
    
    @objc
    func keyboardWillHide(sender: NSNotification) {
        if( keyboardIsVisible == true ){
            keyboardIsVisible = false
            
            let info = sender.userInfo!
            let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            viewBottomConstraint.constant = originalBottomConstraintValue!
            
            UIView.animate(withDuration: duration) { self.containerView.layoutIfNeeded() }
        }
    }
    
    
    func scrollTableViewToBottom(){
        
        if( chatMessages.count > 0 ){
            tableView.scrollToRow(at: IndexPath(row: chatMessages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentMessageSnapshot = chatMessages[indexPath.row]
        let message:String = currentMessageSnapshot.data()["message"] as! String
        let messageUID:String = "4MKh2TuxPDUvwOZ7TYwimEigXb93"
        
//        currentMessageSnapshot.data()["uid"] as! String
//        let messageTimestamp:Date = currentMessageSnapshot.data()["timestamp"] as! Date

        var cell:MessageTableViewCell
        
//        if( messageUID == AuthenticationController.user?.uid ){
//            cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell") as! MessageTableViewCell
//        }
//        else{
            cell = tableView.dequeueReusableCell(withIdentifier: "RemoteChatMessageCell") as! MessageTableViewCell
            cell.profilePhoto?.sd_setImage(with: remoteUser?.photoURL, placeholderImage: UIImage(named: "user-image-default"))
//        }

        cell.messageLabel?.text = message
        
        return cell
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }

        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
        else {
            return true
        }
        
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                if textView.text != "" {
                    textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
                }
            }
        }
    }
    
    @IBAction func sendMessageTapped(_ sender: Any) {
        if messageTextView.text != placeholderText {
            sendMessage()
        }
    }
    
    func sendMessage(){
        // TODO: Sanitize input text
        let messageToAdd:[String : Any] = [
            "uid": (AuthenticationController.user?.uid)!,
            "message": messageTextView.text!,
            "timestamp": Date()]
        
        db.collection("chats").document(chatID!).collection("messages").addDocument(data: messageToAdd, completion: { (error) in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            print("done sending message")
            
        })
        messageTextView.text = ""
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
