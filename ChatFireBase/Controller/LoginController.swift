//
//  LoginController.swift
//  ChatFireBase
//
//  Created by tsb_team on 7/27/16.
//  Copyright © 2016 baon. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}