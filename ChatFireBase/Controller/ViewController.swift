//
//  ViewController.swift
//  ChatFireBase
//
//  Created by tsb_team on 7/27/16.
//  Copyright © 2016 baon. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        if (FIRAuth.auth()?.currentUser?.uid == nil) {
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        }
    }

    func handleLogout() {
        Common.makeIndicator(self.view)
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            Common.hideIndicator()
            print(logoutError)
        }
        let loginController = LoginController()
        presentViewController(loginController, animated: true, completion: nil)
        Common.hideIndicator()
    }

}

