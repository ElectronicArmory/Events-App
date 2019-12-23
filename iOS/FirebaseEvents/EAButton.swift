//
//  EAButton.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

class EAButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = self.frame.size.height/2
        
        titleLabel?.textColor = UIColor(red: 150/255, green: 110/255, blue: 45/255, alpha: 1.0)
    }

}
