//
//  CustomiseJSQMessage.swift
//  hikingbot
//
//  Created by KL on 7/3/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import JSQMessagesViewController

class CustomiseJSQMessage: JSQMessage {
    internal var attachments : [NSURL]?
    
    init(senderId: String!, senderDisplayName: String!, date: NSDate!, text: String!, attachments: [NSURL]?) {
        self.attachments = attachments
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date as Date, text: text)
    }
    
    init(senderId: String!, senderDisplayName: String!, date: NSDate!, media: JSQMessageMediaData!) {
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date as Date, media: media)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
