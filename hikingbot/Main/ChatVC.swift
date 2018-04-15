//
//  ChatVC.swift
//  hikingbot
//
//  Created by KL on 8/2/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import SKYKit

class ChatVC: UIViewController, UITextFieldDelegate{
  
  @IBOutlet var destination: UITextField!
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    self.view.bounds.origin.y = 250
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.view.bounds.origin.y = 0
    self.view.endEditing(true)
    return true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.bounds.origin.y = 0
    self.view.endEditing(true)
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    self.navigationController?.isNavigationBarHidden = true
    self.destination.delegate = self
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
  
  @IBAction func createARView(_ sender: Any) {
    if let loc = destination.text{
      let ARView = HikingARViewController()
      ARView.destination = loc
      let arViewNavigationController = UINavigationController(rootViewController: ARView)
      self.present(arViewNavigationController, animated: true, completion: nil)
    }
    
  }
  
  @IBAction func createChat(_ sender: Any) {
    let chatView = DLchatbotViewController()
    let chatNavigationController = UINavigationController(rootViewController: chatView)
    self.present(chatNavigationController, animated: true, completion: nil)
  }
}

