//
//  CaptureProfilePhotoViewController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
class CaptureProfilePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var takePhotoButton: EAButton!
    @IBOutlet weak var backButton: EAButton!
    
    var isRequired:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if( AuthenticationController.authorizationToken != "" ){
            backButton.isHidden = false
        }
        
        if isRequired == true {
            backButton.isHidden = true
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func takePhotoTapped(_ sender: Any) {
        
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
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        
        let profilePhotoViewController:ProfilePhotoViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProfilePhotoViewController.self)) as! ProfilePhotoViewController
        profilePhotoViewController.isRequired = self.isRequired
        
        if let photoData:UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            profilePhotoViewController.profilePhoto = photoData
        }
        else if let photoData:UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            profilePhotoViewController.profilePhoto = photoData
        }
        
        
        if( navigationController == nil ){
            self.present(profilePhotoViewController, animated: true, completion: nil)
        }
        else{
            navigationController?.pushViewController(profilePhotoViewController, animated: true)
        }
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
