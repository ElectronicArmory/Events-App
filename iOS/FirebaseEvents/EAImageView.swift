//
//  EAImageView.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

class EAImageView: UIImageView {

    var user:EAUser?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.width/2
        self.layer.masksToBounds = true
    }

}
