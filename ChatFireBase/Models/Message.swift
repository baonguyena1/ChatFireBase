/*
 *---------------------------------------------------------------------------
 * File Name      : Message.swift
 * File Code      : UTF-8
 * Create Date    : 7/29/16
 * Copyright      : 2016 by GCS.
 *---------------------------------------------------------------------------
 * ver 1.0.0      : 7/29/16 baon new create
 *---------------------------------------------------------------------------
 * history        :
 *---------------------------------------------------------------------------
 */

import UIKit
import Firebase

class Message: NSObject {
    
    var timestamp: NSNumber?
    var fromId: String?
    var toId: String?
    var text: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    }
}
