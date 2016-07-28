//
//  Common.swift
//  ChatFireBase
//
//  Created by Bao Nguyen on 7/28/16.
//  Copyright © 2016 baon. All rights reserved.
//

import UIKit
import MBProgressHUD

class Common: NSObject {
    
    static var hud: MBProgressHUD!
    
    class func makeIndicator(view: UIView) {
        hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = .Indeterminate
        hud.activityIndicatorColor = UIColor.redColor()
        hud.color = UIColor.whiteColor()
        hud.labelText = "Loading..."
        hud.labelColor = UIColor.grayColor()
    }
    
    class func hideIndicator() {
        hud.hide(true)
    }
}
