//
//  NewsEventsTableViewCell.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

class NewsEventsTableViewCell: EATableViewCell {

    static let NewsEventsCellID:String = "NewsEventsCellID"
    
    @IBOutlet weak var organizerImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var eventPlaceAndTimeLabel: UILabel!
    
    @IBOutlet weak var hostedByLabel: UILabel!
    @IBOutlet weak var hostedByConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        organizerImageView.layer.masksToBounds = true
        organizerImageView.layer.cornerRadius = organizerImageView.frame.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
