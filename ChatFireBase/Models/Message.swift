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
    
    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}
