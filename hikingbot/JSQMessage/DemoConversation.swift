//
//  DemoConversation.swift
//  SwiftExample
//
//  Created by Dan Leonard on 5/11/16.
//  Copyright © 2016 MacMeDan. All rights reserved.
//

import JSQMessagesViewController
import SKYKit
import SKYKitChat

// User Enum to make it easyier to work with.
enum User: String {
    case Bot = "67785199-677e-4f63-8d0d-888eae2971d7"
    case User = "71ad382e-e201-489e-812f-26717991102e"
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
let AvatarIDBot = "67785199-677e-4f63-8d0d-888eae2971d7"
let AvatarIDUser = "71ad382e-e201-489e-812f-26717991102e"

// Create Avatars Once for performance
//
// Create an avatar with Image
let AvatarBot = JSQMessagesAvatarImageFactory().avatarImage(withPlaceholder: UIImage(named:"avatar_bot")!)

let AvatarUser = JSQMessagesAvatarImageFactory().avatarImage(withPlaceholder: UIImage(named:"demo_avatar_jobs")!)

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

// photo message
let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
let photoMessage = JSQMessage(senderId: AvatarIDUser, displayName: getName(User.User), media: photoItem)

// audio mesage
let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
let audioItem = JSQAudioMediaItem(data: audioData)
let audioMessage = JSQMessage(senderId: AvatarIDUser, displayName: getName(User.User), media: audioItem)

func makeNormalConversation() -> [JSQMessage] {
    var conversation = [JSQMessage]()
    conversation = [photoMessage, audioMessage]
    return conversation
}
