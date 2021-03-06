//
//  ChatLogController.swift
//  ChatFireBase
//
//  Created by Bao Nguyen on 7/29/16.
//  Copyright © 2016 baon. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellId = "cellId"
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, toId = user?.id  else {
            return
        }
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message(dictionary: dictionary)
                message.setValuesForKeysWithDictionary(dictionary)
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView?.reloadData()
                        
                        // scroll to the last index
                        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                        self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                    })
                }
                
                
                }, withCancelBlock: nil)
            
            }, withCancelBlock: nil)
    }
    
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
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .Interactive

        setupKeyboardObservers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.whiteColor()
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.contentMode = .ScaleAspectFill
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.userInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        uploadImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        uploadImageView.widthAnchor.constraintEqualToConstant(40).active = true
        uploadImageView.heightAnchor.constraintEqualToConstant(40).active = true
        
        let sendButton = UIButton(type: .System)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        sendButton.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(80).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        containerView.addSubview(self.inputTextField)
        self.inputTextField.leftAnchor.constraintEqualToAnchor(uploadImageView.rightAnchor, constant: 8).active = true
        self.inputTextField.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        self.inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor, constant: 8).active = true
        self.inputTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        let separatorLineView = UIView()
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        separatorLineView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        separatorLineView.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        separatorLineView.heightAnchor.constraintEqualToConstant(1).active = true
        
        return containerView
    }()
    
    func handleUploadTap(recognizer: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPickerView: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPickerView = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPickerView = originalImage
        }
        
        if let selectedImage = selectedImageFromPickerView {
            uploadToFirebaseStorageUsingImage(selectedImage)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func uploadToFirebaseStorageUsingImage(image: UIImage) {
        let imageName = NSUUID().UUIDString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageUrl(imageUrl, image: image)
                }
                
            })
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func handleKeyboardDidShow(notification: NSNotification) {
        if messages.count <= 0 {
            return
        }
        let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
        self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        containerViewBottomAnchor?.constant = 0
        
        UIView.animateWithDuration(keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        
        UIView.animateWithDuration(keyboardDuration!) { 
            self.view.layoutIfNeeded()
        }
        
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func handleSend() {
        let properties: [String: AnyObject] = ["text": inputTextField.text!]
        sendMessageWithProperties(properties)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
        sendMessageWithProperties(properties)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["toId": toId, "fromId": fromId, "timestamp": timeStamp]
        
        // Append properties onto values somehow???
        // key $0, value $1
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            self.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
    
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
        setupCell(cell, message: message)
        
        // let modify the bubbleView's width somehow?
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.hidden = false
        } else if message.imageUrl != nil {
            // fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.hidden = true
        }
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            // outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.whiteColor()
            
            cell.profileImageView.hidden = true
            cell.bubbleViewRightAnchor?.active = true
            cell.bubbleViewLeftAnchor?.active = false
        } else {
            // imcoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.blackColor()
            
            cell.profileImageView.hidden = false
            cell.bubbleViewRightAnchor?.active = false
            cell.bubbleViewLeftAnchor?.active = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.hidden = false
            cell.bubbleView.backgroundColor = UIColor.clearColor()
        } else {
            cell.messageImageView.hidden = true
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var height: CGFloat = 80
        
        // get estimated height somwhow???
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, imageHeight = message.imageHeight?.floatValue {
            // h1/w1 = h2/w2
            // solve for h1
            // h1 = h2/w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.mainScreen().bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        return NSString(string: text).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16)], context: nil)
    }
    
    var startingFrame:CGRect?
    var backgroundView: UIView?
    var startingImageView: UIImageView?
    
    // My custom zooming logic
    func  performZoomInForImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.hidden = true
        
        self.startingFrame = startingImageView.superview?.convertRect(startingImageView.frame, toView: nil)
        print(startingFrame)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.redColor()
        zoomingImageView.image = startingImageView.image
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.userInteractionEnabled = true
        
        if let keyWindow = UIApplication.sharedApplication().keyWindow {
            backgroundView = UIView(frame: keyWindow.frame)
            backgroundView?.backgroundColor = UIColor.blackColor()
            backgroundView?.alpha = 0
            keyWindow.addSubview(backgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: {
                self.backgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRectMake(0, 0, keyWindow.frame.width, height)
                zoomingImageView.center = keyWindow.center
                
                }, completion: nil)
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: { 
                zoomOutImageView.frame = self.startingFrame!
                
                self.backgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                }, completion: { (completion) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.hidden = false
            })
        }
    }
}
