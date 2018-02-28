//
//  ChatViewController.swift
//  SwiftExample
//
//  Created by Dan Leonard on 5/11/16.
//  Copyright © 2016 MacMeDan. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SKYKitChat
import SKYKit

class ChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    let defaults = UserDefaults.standard
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    fileprivate var displayName: String!
    var fetchConversation: SKYConversation!
    var skykitMessages: [SKYMessage]!
    
    // MARK: - Send, back, assisted Buttons
    func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func receiveMessagePressed(_ sender: UIBarButtonItem) {
        skyMessageToJSQMessage()
    }
    
    // MARK: - SKYKitChat
    func fetchChatrecord(){
        SKYContainer.default().chatExtension?.fetchConversations(
            fetchLastMessage: false,
            completion: { (conversations, error) in
                if let _ = error {
                    let alert = UIAlertController(title: "Error on fetching the conversations", message: "Do you want to try again?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                        self.fetchChatrecord()
                    }))
                    self.present(alert, animated: true)
                    return
                }
                
                if let fetchedConversations = conversations {
                    self.fetchConversation = fetchedConversations[0]
                    print("Fetched \(fetchedConversations.count) conversations.")
                    self.loadingConversation()
                    self.subscribeNewMessages()
                }
        })
    }
    
    func loadingConversation(){
        SKYContainer.default().chatExtension?.fetchMessages(
            conversation: fetchConversation,
            limit: 100,
            beforeTime: nil,
            order: "created_at",
            completion: { (messages, _ ,error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error on fetching the ,essages", message: "Do you want to try again?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                        self.loadingConversation()
                    }))
                    self.present(alert, animated: true)
                    return
                }

                if let fetchedMessages = messages{
                    self.skykitMessages = fetchedMessages
                    self.skyMessageToJSQMessage()
                    print ("Messages fetched")
                }
        })
    }
    
    func sendChat(text: String){
        let message = SKYMessage()
        message.body = text
        
        SKYContainer.default().chatExtension?.addMessage(message,
                                                         to: fetchConversation) { (message, error) in
                                                            if let err = error {
                                                                print("Send message error: \(err.localizedDescription)")
                                                                return
                                                            }
                                                            
                                                            if message != nil {
                                                                print("Send message successful")
                                                            }
        }
    }
    
    func skyMessageToJSQMessage(){
        messages = [JSQMessage]()
        for skykitMessage in skykitMessages{
            let message = JSQMessage(senderId: skykitMessage.creatorUserRecordID(), senderDisplayName: "nil", date: skykitMessage.creationDate(), text: skykitMessage.body!)
            messages.append(message)
        }
        messages.reverse()
        self.finishSendingMessage(animated: true)
        self.scrollToBottom(animated: true)
    }
    
    func subscribeNewMessages(){
        SKYContainer.default().chatExtension?.subscribeToMessages(
            in: fetchConversation,
            handler: { (event, message) in
                print("Received message event")
                let message = JSQMessage(senderId: message.creatorUserRecordID(), senderDisplayName: "nil", date: message.creationDate(), text: message.body!)
                self.messages.append(message)
                self.finishSendingMessage(animated: true)
                self.scrollToBottom(animated: true)
        })
    }
    
    // MARK: - JSQMessagesViewController method overrides
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        sendChat(text: text)
        self.finishSendingMessage(animated: true)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Send photo", style: .default) { (action) in
            /**
             *  Create fake photo
             */
            let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
            self.addMedia(photoItem)
        }
        
        let locationAction = UIAlertAction(title: "Send location", style: .default) { (action) in
            /**
             *  Add fake location
             */
            let locationItem = self.buildLocationItem()
            
            self.addMedia(locationItem)
        }
        
        let videoAction = UIAlertAction(title: "Send video", style: .default) { (action) in
            /**
             *  Add fake video
             */
            let videoItem = self.buildVideoItem()
            
            self.addMedia(videoItem)
        }
        
        let audioAction = UIAlertAction(title: "Send audio", style: .default) { (action) in
            /**
             *  Add fake audio
             */
            let audioItem = self.buildAudioItem()
            
            self.addMedia(audioItem)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(photoAction)
        sheet.addAction(locationAction)
        sheet.addAction(videoAction)
        sheet.addAction(audioAction)
        sheet.addAction(cancelAction)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func buildVideoItem() -> JSQVideoMediaItem {
        let videoURL = URL(fileURLWithPath: "file://")
        
        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        
        return videoItem
    }
    
    func buildAudioItem() -> JSQAudioMediaItem {
        let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
        let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
        
        let audioItem = JSQAudioMediaItem(data: audioData)
        
        return audioItem
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    func addMedia(_ media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId(), displayName: self.senderDisplayName(), media: media)
        self.messages.append(message)
        
        //Optional: play sent sound
        
        self.finishSendingMessage(animated: true)
    }

    //MARK: JSQMessages CollectionView DataSource
    override func senderId() -> String {
        return (SKYContainer.default().auth.currentUser?.ownerUserRecordID)!
    }
    
    override func senderDisplayName() -> String {
        return getName(.User)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        
        return messages[indexPath.item].senderId == self.senderId() ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = messages[indexPath.item]
        return getAvatar(message.senderId)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        // Force hide display name, Uncomment the code below to enable displaying name
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if indexPath.item % 5 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        return 0.0;
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Skygear Chat
        fetchChatrecord()
        
        // Setup navigation
        setupBackButton()
        
        // Scroll the chat to the bottom
        self.scrollToBottom(animated: true)
        
        // Bubbles with tails
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.lightGray)
        
        
        // Showing Avatars
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        
        // Show Button to simulate incoming messages
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.jsq_defaultTypingIndicator(), style: .plain, target: self, action: #selector(receiveMessagePressed))
        
        // This is a beta feature that mostly works but to make things more stable it is diabled.
        collectionView?.collectionViewLayout.springinessEnabled = false
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
    }
    
}
