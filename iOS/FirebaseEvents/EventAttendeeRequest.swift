//
//  EventAttendeeRequest.swift
//  FirebaseEvents
//
//  Created by Mike Z on 11/14/19.
//  Copyright © 2019 Electronic Armory. All rights reserved.
//

import UIKit
import FirebaseFirestore


class EventAttendeeRequest: NSObject {
    var attendeeUID:String?
    var attendeeDisplayName:String?
    var attendeeProfileURL:URL?
    
    var eventID:String?
    var timestamp:Timestamp?
    var originatorUID:String?

    var event:EAEvent = EAEvent()
}
