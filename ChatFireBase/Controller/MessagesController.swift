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
    
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_message_icon"), style: .Plain, target: self, action: #selector(handleNewMessage))
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserIsLoggedIn()
        
//        observeMessage()
        obseverUserMessage()
    }
    
    func obseverUserMessage() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageId = snapshot.key
            let messageReference = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messageReference.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.setValuesForKeysWithDictionary(dictionary)
                    
                    if let charParnerId = message.chatPartnerId() {
                        self.messageDictionary[charParnerId] = message
                        self.messages = Array(self.messageDictionary.values)
                        self.messages.sortInPlace({ (message1, message2) -> Bool in
                            return message1.timestamp?.intValue > message2.timestamp?.intValue
                        })
                    }
                    
                    self.timer?.invalidate()
                    print("We just caneled out timer")
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    print("schedule a table reload in 0.1 sec")
                }
                
                }, withCancelBlock: nil)
            
            }, withCancelBlock: nil)
    }
    
    var timer: NSTimer?
    
    func handleReloadTable() {
        dispatch_async(dispatch_get_main_queue(), {
            print("we reloaded the table")
            self.tableView.reloadData()
        })
    }
    
    func observeMessage() {
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeysWithDictionary(dictionary)

                if let toId = message.toId {
                    self.messageDictionary[toId] = message
                    self.messages = Array(self.messageDictionary.values)
                    self.messages.sortInPlace({ (message1, message2) -> Bool in
                        return message1.timestamp?.intValue > message2.timestamp?.intValue
                    })
                }
                
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView.reloadData()
                })
            }
            
            }, withCancelBlock: nil)
        
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesContrller = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if (FIRAuth.auth()?.currentUser?.uid == nil) {
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        Common.makeIndicator(self.view)
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
//                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                user.setValuesForKeysWithDictionary(dictionary)
                self.setupNavbarWithUser(user)
            }
            Common.hideIndicator()
            
            }, withCancelBlock: { (error) in
                Common.hideIndicator()
        })
    }
    
    func setupNavbarWithUser(user: User) {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        obseverUserMessage()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .ScaleAspectFill
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(40).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(40).active = true
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        nameLabel.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8).active = true
        nameLabel.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        nameLabel.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        nameLabel.heightAnchor.constraintEqualToAnchor(profileImageView.heightAnchor).active = true
        
        containerView.centerXAnchor.constraintEqualToAnchor(titleView.centerXAnchor).active = true
        containerView.centerYAnchor.constraintEqualToAnchor(titleView.centerYAnchor).active = true

        navigationItem.titleView = titleView
        
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
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
        loginController.messagesController = self
        presentViewController(loginController, animated: true, completion: nil)
        Common.hideIndicator()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        let message = messages[indexPath.row]
        
        cell.message = message
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeysWithDictionary(dictionary)
            self.showChatControllerForUser(user)
            
            
            }, withCancelBlock: nil)
    }
    
    
    
}

