//
//  MessageTableViewCell.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if( profilePhoto != nil ){
            profilePhoto.layer.masksToBounds = true
            profilePhoto.layer.cornerRadius = profilePhoto.frame.width/8
        }
        messageContainer.layer.masksToBounds = true
        messageContainer.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
