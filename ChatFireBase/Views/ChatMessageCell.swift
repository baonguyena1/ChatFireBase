//
//  ChatMessageCell.swift
//  ChatFireBase
//
//  Created by gcsvn on 8/2/16.
//  Copyright © 2016 baon. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    lazy var textView: UITextView = {
       let tv = UITextView()
        tv.text = "SAMPLE TEXT FOR NOW"
        tv.font = UIFont.systemFontOfSize(16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        
        textView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        textView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        textView.widthAnchor.constraintEqualToConstant(200).active = true
        textView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
