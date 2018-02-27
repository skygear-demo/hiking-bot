//
//  DemoConversation.swift
//  SwiftExample
//
//  Created by Dan Leonard on 5/11/16.
//  Copyright © 2016 MacMeDan. All rights reserved.
//

import JSQMessagesViewController

// User Enum to make it easyier to work with.
enum User: String {
    case Bot    = "053496-4509-288"
    case User    = "309-41802-93823"
}

// Helper Function to get usernames for a secific User.
func getName(_ user: User) -> String{
    switch user {
    case .User:
        return "User name"
    case .Bot:
        return "Hiking Bot"
    }
}


// Create Unique IDs for avatars
let AvatarIDBot = "053496-4509-288"
let AvatarIDUser = "309-41802-93823"

// Create Avatars Once for performance
//
// Create an avatar with Image
let AvatarBot = JSQMessagesAvatarImageFactory().avatarImage(withPlaceholder: UIImage(named:"avatar_bot")!)

let AvatarUser = JSQMessagesAvatarImageFactory().avatarImage(withUserInitials: "SW", backgroundColor: UIColor.jsq_messageBubbleGreen(), textColor: UIColor.white, font: UIFont.systemFont(ofSize: 12))

// Helper Method for getting an avatar for a specific User.
func getAvatar(_ id: String) -> JSQMessagesAvatarImage{
    let user = User(rawValue: id)!
    
    switch user {
    case .Bot:
        return AvatarBot
    case .User:
        return AvatarUser
    }
}

// INFO: Creating Static Demo Data. This is only for the exsample project to show the framework at work.
var conversationsList = [Conversation]()

var convo = Conversation(firstName: "Steave", lastName: "Jobs", preferredName:  "Stevie", smsNumber: "(987)987-9879", id: "33", latestMessage: "Holy Guacamole, JSQ in swift", isRead: false)

var conversation = [JSQMessage]()

let message = JSQMessage(senderId: AvatarIDBot, displayName: getName(User.Bot), text: "What is this Black Majic?")
let message2 = JSQMessage(senderId: AvatarIDBot, displayName: getName(User.Bot), text: "It is simple, elegant, and easy to use. There are super sweet default settings, but you can customize like crazy")
let message3 = JSQMessage(senderId: AvatarIDBot, displayName: getName(User.Bot), text: "It even has data detectors. You can call me tonight. My cell number is 123-456-7890. My website is www.hexedbits.com.")
let message4 = JSQMessage(senderId: AvatarIDBot, displayName: getName(User.Bot), text: "JSQMessagesViewController is nearly an exact replica of the iOS Messages App. And perhaps, better.")
let message5 = JSQMessage(senderId: AvatarIDBot, displayName: getName(User.Bot), text: "It is unit-tested, free, open-source, and documented.")
let message6 = JSQMessage(senderId: AvatarIDBot, displayName: getName(User.Bot), text: "This is incredible")
let message7 = JSQMessage(senderId: AvatarIDUser, displayName: getName(User.User), text: "I would have to agree")
let message8 = JSQMessage(senderId: AvatarIDBot, displayName: getName(User.Bot), text: "It is unit-tested, free, open-source, and documented like a boss.")
let message9 = JSQMessage(senderId: AvatarIDUser, displayName: getName(User.User), text: "You guys need an award for this, I'll talk to my people at Apple. 💯 💯 💯")

// photo message
let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
let photoMessage = JSQMessage(senderId: AvatarIDUser, displayName: getName(User.User), media: photoItem)

// audio mesage
let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
let audioItem = JSQAudioMediaItem(data: audioData)
let audioMessage = JSQMessage(senderId: AvatarIDUser, displayName: getName(User.User), media: audioItem)


func makeNormalConversation() -> [JSQMessage] {
    conversation = [message, message2, message3, message4, message5, message6, message7, message8, message9, photoMessage, audioMessage]
    return conversation
}
