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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_message_icon"), style: .Plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navigationController = UINavigationController(rootViewController: newMessageController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if (FIRAuth.auth()?.currentUser?.uid == nil) {
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        } else {
            Common.makeIndicator(self.view)
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
                Common.hideIndicator()
                }, withCancelBlock: { (error) in
                    Common.hideIndicator()
            })
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

