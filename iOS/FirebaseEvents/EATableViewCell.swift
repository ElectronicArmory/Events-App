//
//  EATableViewCell.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

class EATableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImagebutton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if containerView != nil {
            containerView.layer.cornerRadius = 18
        }
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
