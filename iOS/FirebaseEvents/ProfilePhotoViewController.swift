//
//  ProfilePhotoViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

class ProfilePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    @IBOutlet weak var nextButton: EAButton!
    @IBOutlet weak var retakeButton: EAButton!
    
    var profilePhoto:UIImage? = nil
    
    var isRequired = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePhotoImageView.image = profilePhoto
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func retakeTapped(_ sender: Any) {
        let photoPickerController:UIImagePickerController = UIImagePickerController()
        photoPickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        let photoSelectionAlert:UIAlertController = UIAlertController(title: "Where is your profile photo?", message: nil, preferredStyle: .actionSheet)
        photoSelectionAlert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (alertAction) in
            photoPickerController.sourceType = .photoLibrary
            self.present(photoPickerController, animated: true, completion: nil)
        }))
        photoSelectionAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alertAction) in
            if( UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) ) {
                photoPickerController.sourceType = .camera
            }
            else{
                photoPickerController.sourceType = .photoLibrary
            }
            photoPickerController.allowsEditing = true
            self.present(photoPickerController, animated: true, completion: nil)
        }))
        
        self.present(photoSelectionAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func nextTapped(_ sender: Any) {
        UserMessagingController.startLoadingHUD(message: "Uploading your image...")
        
        let resizedProfileImage:UIImage = (profilePhoto?.resizeWithWidth(width: 960.0))!
        
        RemoteStorageController.uploadUserProfilePicture(photoData: resizedProfileImage.jpegData(compressionQuality: 0.8)!, completion: {
            
            UserMessagingController.stopLoadingHUD()
            
            if( self.isRequired == true ){
                let profileFinishViewController:ProfileFinishViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileFinishViewController.self)) as! ProfileFinishViewController
                
                if self.navigationController != nil {
                    self.navigationController?.pushViewController(profileFinishViewController, animated: true)
                }
                else{
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                }
            }
            else{
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("PROFILE_NEW_PHOTO"), object: nil)
        })
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        
        if let photoData:UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            self.profilePhoto = photoData
        }
        else if let photoData:UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            self.profilePhoto = photoData
        }
        
        profilePhotoImageView.image = self.profilePhoto
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
