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
    

    @IBOutlet var loadingView: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let chatView = DLchatbotViewController()
        let chatNavigationController = UINavigationController(rootViewController: chatView)
        self.present(chatNavigationController, animated: true, completion: nil)
    }
}

