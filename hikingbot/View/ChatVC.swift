//
//  ChatVC.swift
//  hikingbot
//
//  Created by KL on 8/2/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import SKYKit

class ChatVC: UIViewController {
    
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(SKYContainer.default().auth.currentUser?.ownerUserRecordID)
    }
    
    // MARK: - Actions
    @IBAction func signOut(_ sender: Any) {
        SKYContainer.default().auth.logout { (user, error) in
            if let error = error {
                print("Logout error: \(error)")
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func createChat(_ sender: Any) {
        fetchChatrecord()
    }
    
    @IBAction func createConversation(_ sender: Any) {
        if let id = userIdTextField.text, !id.isEmpty {
            SKYContainer.default().chatExtension?.createDirectConversation(userID: id, title: "Chat with bot", metadata: nil) { (conversation, error) in
                if let err = error {
                    let alert = UIAlertController(title: "Unable to create direct conversation", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                print("The id is \(conversation?.recordID().canonicalString ?? "null")")
            }
        }
    }
    
    // MARK: - Functions
    func fetchChatrecord(){
        self.loadingView.startAnimating()
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
                    self.loadingView.stopAnimating()
                    return
                }
                
                if let fetchedConversations = conversations {
                    let chatView = ChatViewController()
                    chatView.fetchConversation = fetchedConversations[0]
                    let chatNavigationController = UINavigationController(rootViewController: chatView)
                    self.present(chatNavigationController, animated: true, completion: nil)
                    self.loadingView.stopAnimating()
                }
        })
    }
}

