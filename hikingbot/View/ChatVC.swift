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
        let chatView = ChatViewController()
        let chatNavigationController = UINavigationController(rootViewController: chatView)
        present(chatNavigationController, animated: true, completion: nil)
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

}
