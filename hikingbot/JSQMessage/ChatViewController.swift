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
    var fetchConversation: SKYConversation!
    var skykitMessages: [SKYMessage]!
    
    // MARK: - Send, back Buttons
    func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - assisted Buttons
    @objc func receiveMessagePressed(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - SKYKitChat
    func loadingConversation(){
        SKYContainer.default().chatExtension?.fetchMessages(
            conversation: fetchConversation,
            limit: 20,
            beforeTime: nil,
            order: "created_at",
            completion: { (messages, _ ,error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error on fetching the ,messages", message: "Do you want to try again?", preferredStyle: .alert)
                    
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
    }
    
    func subscribeNewMessages(){
        SKYContainer.default().chatExtension?.subscribeToMessages(
            in: fetchConversation,
            handler: { (event, message) in
                print("Received message event")
                self.loadingConversation()
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
        let message = JSQMessage(senderId: self.senderId(), displayName: "nil", media: media)
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        return 10.0;
    }
    
    // MARK: - Override
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Customization of the chat bubble.
        let cell : JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let msg = self.messages[indexPath.row]
        if(msg.senderId == self.senderId()){
            cell.textView?.textColor = UIColor.white //change this color for your messages
        }else{
            cell.textView?.textColor = UIColor.white //change this color for other people message
        }
       // cell.textView?.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.blue] //this is the color of the links
        
        return cell
    }

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Skygear Chat
        self.loadingConversation()
        self.subscribeNewMessages()
        
        // Setup navigation
        setupBackButton()
        
        // customise input view
        self.inputToolbar.contentView?.textView?.placeHolder = "Ask the bot question"
        self.inputToolbar.contentView?.textView?.autocorrectionType = UITextAutocorrectionType.no
        
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

