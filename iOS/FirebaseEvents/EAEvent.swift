//
//  EAEvent.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit

class EAEvent: NSObject {
    var eventID:String?
    var eventOriginatorID:String?
    var eventDate:Date?
    var eventEndDate:Date?
    var eventTopic:String?
    var eventDescription:String?
    
    var eventLocation:EALocation?
    
    var eventOriginatorImage:UIImage?
    
    var eventTicketURL:URL?
    var eventVirtualMeetingURL:URL?
    
    var eventHost:String?
}
