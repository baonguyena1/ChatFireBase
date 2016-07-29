//
//  ChatLogController.swift
//  ChatFireBase
//
//  Created by Bao Nguyen on 7/29/16.
//  Copyright © 2016 baon. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
    lazy var inputTextField: UITextField = {
        let inputTextField = UITextField()
        inputTextField.placeholder = "Enter message..."
        inputTextField.autocorrectionType = .No
        inputTextField.clearButtonMode = .WhileEditing
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        return inputTextField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.backgroundColor = UIColor.whiteColor()

        navigationItem.title = "Chat Log Controller"
        setupInputComponents()
    }

    func setupInputComponents() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        containerView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        containerView.heightAnchor.constraintEqualToConstant(50).active = true
        
        let sendButton = UIButton(type: .System)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        sendButton.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(80).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 8).active = true
        inputTextField.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor, constant: 8).active = true
        inputTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true

        let separatorLineView = UIView()
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        containerView.addSubview(separatorLineView)

        separatorLineView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        separatorLineView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        separatorLineView.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        separatorLineView.heightAnchor.constraintEqualToConstant(1).active = true
    }
    
    func handleSend() {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let values = ["text": inputTextField.text!]
        childRef.updateChildValues(values)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
}
