//
//  ChatViewController.swift
//  SwiftExample
//
//  Created by Dan Leonard on 5/11/16.
//  Copyright © 2016 MacMeDan. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import ApiAI
import AVFoundation
import SKYKit


class DLchatbotViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    var incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: (UIColor(displayP3Red: CGFloat(72.0/255.0), green: CGFloat(142.0/255.0), blue: CGFloat(248.0/255.0), alpha: 1.0)))
    var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.init(red: 42/255.0, green: 177/255.0, blue: 229/255.0, alpha: 1))
    let welcomeMessage = "Hi, I am Master Hike. What can I do for you? You can start by click suggestion button."
    let speechSynthesizer = AVSpeechSynthesizer()
    var isMute = false
    var suggestions: [String] = []
    let VIEWHEIGHT: CGFloat = 50

    // MARK: - Suggestion
    func showSuggestinoKeyword(){
        let viewWidth = self.view.bounds.width
        let buttonHeight: CGFloat = VIEWHEIGHT - 20
        let buttonWidth = (self.view.bounds.width - 40)/3
        
        view.viewWithTag(100)?.removeFromSuperview()
        let selectableView = UIView(frame: CGRect(x: 0, y: self.inputToolbar.frame.origin.y - VIEWHEIGHT, width: viewWidth, height: VIEWHEIGHT))
        var tmpX: CGFloat = 10
        selectableView.tag = 100
        
        for suggestion in suggestions{
            let button = RoundButton(frame: CGRect(x: tmpX, y: 10, width: buttonWidth, height: buttonHeight))
            button.setTitle(suggestion, for: .normal)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addTarget(self, action:#selector(sendSuggestionChat), for: .touchUpInside)
            selectableView.addSubview(button)
            tmpX += 10 + buttonWidth
        }
        
        self.view.addSubview(selectableView)
    }
    
    @objc func sendSuggestionChat(sender:UIButton!) {
        view.viewWithTag(100)?.removeFromSuperview()
        let body = sender.titleLabel?.text
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: body)
        messages.append(message!)
        finishSendingMessage()
        passMessageToBot(body: body!)
    }
    
    // MARK: - Speech to Text Function
    func speechAndText(text: String?) {
        if !isMute{
            let speechUtterance = AVSpeechUtterance(string: text!)
            if let textToSpeech = text{
                if NLP.determineLanguage(for: textToSpeech) == "zh-Hant"{
                    speechUtterance.voice  = AVSpeechSynthesisVoice(language: "zh-HK") //usg chinese
                }
                speechSynthesizer.speak(speechUtterance)
            }
        }
    }
    
    // MARK: - Handle intent
    func intentHandler(response: AIResponse){
        if let intent = response.result.metadata.intentName{
            print(intent)
            if (intent == "Default Fallback Intent"){
                self.showSuggestinoKeyword()
            }else if (intent == "weather intent" && !response.result.actionIncomplete.boolValue){
                let date = response.result.parameters["date"] as! AIResponseParameter
                getWeatherFromServer(date: date.stringValue, completion: { (sucess, text) in
                    if sucess{
                        self.messages.append(JSQMessage(senderId: "bot", displayName: "bot", text: text))
                        self.finishReceivingMessage()
                        self.speechAndText(text: text)
                    }else{
                        let msg = "Sorry. I can get find the weather. Please try again."
                        self.messages.append(JSQMessage(senderId: "bot", displayName: "bot", text: msg))
                        self.finishReceivingMessage()
                        self.speechAndText(text: msg)
                    }
                })
            }else if (intent == "Show hike location intent" && !response.result.actionIncomplete.boolValue){
                let loc = response.result.parameters["Hike"] as! AIResponseParameter
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let vc = MapViewController()
                    vc.destinations = [loc.stringValue]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    // MARK: - Method
    func getWeatherFromServer(date: String, completion: @escaping (_ success: Bool, _ text: String)->()) {
        
        let inPredicate = NSPredicate(format: "Date IN %@", [date])
        let query = SKYQuery(recordType: "Weather", predicate: inPredicate)
        var result = " "
        print(date)
        
        SKYContainer.default().publicCloudDatabase.perform(query) { (results, error) in

            if error != nil {
                completion(false, result)
                return
            }
            print("ds")
            for record in results as! [SKYRecord] {
                
                let queryDate = record["Date"] as! String
                print(queryDate)
                if queryDate == date{
                    result = record["Summary"] as! String
                    completion(true, result)
                    return
                }
            }
            completion(false, result)
        }
    }
    
    // MARK: - Diaglog Flow Api
    func passMessageToBot(body: String){
        let request = ApiAI.shared().textRequest()
        request?.query = body
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse

            let textResponse = response.result.fulfillment.messages[0]["speech"] as! String
            
            // Append the resopnse message to the conversation
            self.messages.append(JSQMessage(senderId: "bot", displayName: "bot", text: textResponse))
            self.finishReceivingMessage()
            self.speechAndText(text: textResponse)
            
            // Handle special intent
            self.intentHandler(response: response)
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
    }
    
    // MARK: - Delegate with textField & Scrolling
    override func textViewDidBeginEditing(_ textView: UITextView) {
        self.scrollToBottom(animated: true)
        if let subview = view.viewWithTag(100){
            subview.frame.origin.y = self.inputToolbar.frame.origin.y - VIEWHEIGHT
        }
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        if let subview = view.viewWithTag(100){
            subview.frame.origin.y = self.view.frame.size.height - self.inputToolbar.frame.height - VIEWHEIGHT
        }
    }
    
    override func finishSendingMessage() {
        super.finishSendingMessage()
        self.scrollToBottom(animated: true)
    }
    
    // MARK: - Input tool bar button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        messages.append(message!)
        finishSendingMessage()
        passMessageToBot(body: text)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        
        let sheet = UIAlertController(title: "More fuction", message: nil, preferredStyle: .actionSheet)
        let translateAction = UIAlertAction(title: "中文翻譯", style: .default) { (action) in
            let lastMessageIndex = self.messages.count - 1
            GoogleTranslateAPI.requestTranslation(target: "zh-TW", textToTranslate: self.messages[self.messages.count - 1].text) { (success, result) in
                self.messages[lastMessageIndex] = JSQMessage(senderId: self.messages[lastMessageIndex].senderId, displayName: self.messages[lastMessageIndex].senderDisplayName, text: result)
                self.finishSendingMessage()
                self.speechAndText(text: result)
            }
            self.scrollToBottom(animated: true)
        }
        let suggestAction = UIAlertAction(title: "Suggestion", style: .default) { (action) in
            self.suggestions = NLP.getThreeRandomNonRepeatedKeyword()
            self.showSuggestinoKeyword()
            self.scrollToBottom(animated: true)
        }
        
        let hikeAction = UIAlertAction(title: "Hike Suggestion", style: .default) { (action) in
            self.suggestions = NLP.getThreeRandomHikeKeyword()
            self.showSuggestinoKeyword()
            self.scrollToBottom(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
            self.scrollToBottom(animated: true)
        }
        sheet.addAction(translateAction)
        sheet.addAction(hikeAction)
        sheet.addAction(suggestAction)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = "UserId"
        self.senderDisplayName = "UserId"
        self.suggestions = NLP.getThreeRandomNonRepeatedKeyword()
        
        messages.append(JSQMessage(senderId: "bot", displayName: "bot", text: welcomeMessage))
        
        self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "add.png"), for: UIControlState.normal)
        self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "add.png"), for: UIControlState.highlighted)
        self.inputToolbar.contentView.leftBarButtonItem.image
        self.collectionView.backgroundColor = UIColor(displayP3Red: CGFloat(239.0/255.0), green: CGFloat(242.0/255.0), blue: CGFloat(253.0/255.0), alpha: 1.0)
        
        // Navigation item
        setupNavigationBar()
        
        // Register footer in the collection view
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")
        self.collectionView.delegate = self
        
        /// View Controll Setting
        self.collectionView.contentInsetAdjustmentBehavior = .never
        collectionView?.collectionViewLayout.springinessEnabled = false
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.inputToolbar.contentView.textView.endEditing(true)
    }
    
    // MARK: - Navigation bar
    func setupNavigationBar() {
        navigationItem.title = "Hike Master"
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        let button = UIBarButtonItem(image: UIImage(named: "mute"), style: .plain, target: self, action: #selector(muteButtonPressed))
        button.accessibilityLabel = "Disable play reply message automatically"
        navigationItem.rightBarButtonItem = button
    }
    
    @objc func backButtonTapped() {
        self.inputToolbar.contentView.textView.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func muteButtonPressed(_ sender: UIBarButtonItem) {
        if isMute{
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "mute")
            self.navigationItem.rightBarButtonItem?.accessibilityLabel = "Enable play reply message automatically"
            isMute = false
        }else{
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "notmute")
            self.navigationItem.rightBarButtonItem?.accessibilityLabel = "Disable play reply message automatically"
            isMute = true
        }
    }
    
    // MARK: - JSQMessage View Controll
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return 0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        if (messages[indexPath.row].senderId == self.senderId){
            return JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: UIImage(named:"avatar_user")!, diameter: 100)
        }
        return JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: UIImage(named:"avatar_bot")!, diameter: 100)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.bounds.width, height: 50)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView = UICollectionReusableView()
        reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath)
        
        return reusableView
    }
    
}

