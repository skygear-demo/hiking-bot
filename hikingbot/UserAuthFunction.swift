//
//  UserAuthFunction.swift
//  hikingbot
//
//  Created by KL on 6/2/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation
import SKYKit

class UserAuthFunction: UIViewController{
    
    func resetPassword(email: String){
        SKYContainer.default().auth.forgotPassword(withEmail: email) { (hash, error) in
            guard error == nil else{
                print("error")
                return
            }
            self.presentAlert(title: "Successful", message: "Please check your email to get the link for reset password")
        }
    }
    
    func getLatestUserInfo(){
        SKYContainer.default().auth.getWhoAmI { (user, error) in
            guard error == nil else{
                print(error?.localizedDescription as Any)
                return
            }
            print("getLatestUserInfo() is running.")
        }
    }
    
    func obserUserStauts(){
        // toggle if user login or logout
        NotificationCenter.default.addObserver(forName: Notification.Name.SKYContainerDidChangeCurrentUser,
                                               object: nil,
                                               queue: OperationQueue.main) { (note) in
                                                print("obserUserStauts() is running.")
        }
    }
    
    func changePassword(email: String, oldPw: String, newPw: String){
        SKYContainer.default().auth.login(withEmail: email, password: oldPw) { (user, error) in
            guard error == nil else{
                self.presentAlert(title: "Error", message: "Wrong email or old password")
                return
            }
            SKYContainer.default().auth.setNewPassword(newPw, oldPassword: oldPw) { (user, error) in
                if let error = error {
                    self.presentAlert(title: "Error", message: "Error occur: \(error)")
                    return
                }
                print("password changed successfully")
                self.presentAlert(title: "Successfully", message: "Your password has been changed.")
            }
        }
    }
    
    func loginViaEmail(email: String, pw: String){
        SKYContainer.default().auth.login(withEmail: email, password: pw) { (user, error) in
            guard error == nil else{
                self.presentAlert(title: "Error", message: "Wrong email or password")
                return
            }
            print("login successful")
        }
    }
    
    func signOut(){
        SKYContainer.default().auth.logout { (user, error) in
            if let error = error {
                print("Logout error: \(error)")
                return
            }
            print("Logout success")
            
        }
    }
    
    func signUp(name: String, email: String, pw: String){
        SKYContainer.default().auth.signup(withEmail: email,
                                           password: pw,
                                           profileDictionary: ["username": name]) { (user, error) in
                                            if let error = error{
                                                print("error signing up user: \(error)")
                                                return
                                            }
                                            
                                            guard user != nil else{ return }
                                            print("sign up successful")
                                            print("user record: \(user!)")
                                            print("User name: \(user!["username"])")
                                            
                                            
        }
    }
    
    func presentAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Confirm", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        //self.present(alertController, animated: true, completion: nil)
    }
    

}
