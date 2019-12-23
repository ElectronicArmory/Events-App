//
//  RemoteStorageController.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import Firebase


class RemoteStorageController: NSObject {

    static let storage = Storage.storage()
    static var profilePhotoUploadTask:StorageUploadTask? = nil
    
    static func uploadUserProfilePicture(photoData:Data, completion: @escaping()->Void){
        
        let storageRef = storage.reference()

        // Create a reference to the file you want to upload
        let profileLocation:String = "profile-photos/" + (Auth.auth().currentUser?.uid)! + ".jpg"
        let photoRef = storageRef.child(profileLocation)
        
        // Upload the file to the path "images/rivers.jpg"
        profilePhotoUploadTask = photoRef.putData(photoData, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                
                return
            }
            // Metadata contains file metadata such as size, content-type.
//            let size = metadata.size
            // You can also access to download URL after upload.
            photoRef.downloadURL { (url, error) in
                
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    print(error!.localizedDescription)
                    return
                }
                ProfileController.updateUserProfileURL(newURL: downloadURL)
                completion()
            }
        }

    }
}

