//
//  LoginVC.swift
//  hikingbot
//
//  Created by KL on 6/2/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import SKYKit

class LoginVC: UIViewController {

    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet var rmbEmailSwitch: UISwitch!
    
    // MARK: - Action
    
    @IBAction func loginAction(_ sender: Any) {
        saveEmail()
        loginViaEmail(email: emailTxt.text!, pw: passwordTxt.text!)
    }
    
    @IBAction func registerAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Register", message: "Please fill in all infomation", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Register", style: .default) { (_) in
            if (alertController.textFields?[0].text?.count)! < 3 || (alertController.textFields?[0].text?.count)! > 25{
                self.presentAlert(title: "Error", message: "The length of your name should between 3 and 25.")
            }else if !(self.isValidEmail(emailstr: (alertController.textFields?[1].text)!)){
                self.presentAlert(title: "Error", message: "Your email is not vaild.")
            }else if alertController.textFields?[2].text != alertController.textFields?[3].text{
                 self.presentAlert(title: "Error", message: "Two passwords are not the same.")
            }else{
                self.loading.startAnimating()
                self.signUp(name: (alertController.textFields?[0].text)!, email: (alertController.textFields?[1].text)!, pw: (alertController.textFields?[2].text)!)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "your name"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "example@abc.com"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "confirm password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func forgotPwAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Reset password", message: "Please input your email:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            self.loading.startAnimating()
            self.resetPassword(email: (alertController.textFields?[0].text)!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "example@abc.com"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Function
    
    func signUp(name: String, email: String, pw: String){
        SKYContainer.default().auth.signup(withEmail: email,
                                           password: pw,
                                           profileDictionary: ["username": name]) { (user, error) in
                                            self.loading.stopAnimating()
                                            if let error = error{
                                                self.presentAlert(title: "Error", message: "error signing up user: \(error)")
                                                return
                                            }
                                            
                                            guard user != nil else{ return }
                                            self.presentAlert(title: "Successful", message: "sign up successful")
        }
    }
    
    func isValidEmail(emailstr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailstr)
    }
    
    func saveEmail(){
        if rmbEmailSwitch.isOn{
            UserDefaults.standard.set(emailTxt.text!, forKey: "email")
            UserDefaults.standard.set(true, forKey: "shouldSaveEmail")
        }else{
            UserDefaults.standard.set(false, forKey: "shouldSaveEmail")
        }
    }
    
    func loadSavedEmail(){
        if UserDefaults.standard.bool(forKey: "shouldSaveEmail"){
            rmbEmailSwitch.isOn = true
            if let email = UserDefaults.standard.string(forKey: "email"){
                emailTxt.text = email
            }
        }else{
            rmbEmailSwitch.isOn = false
        }
    }
    
    func resetPassword(email: String){
        SKYContainer.default().auth.forgotPassword(withEmail: email) { (hash, error) in
            self.loading.stopAnimating()
            guard error == nil else{
                 self.presentAlert(title: "Fail", message: "Please try again with vaild email address")
                return
            }
            self.presentAlert(title: "Successful", message: "reset password link has been sent to \(email)")
        }
    }
    
    func loginViaEmail(email: String, pw: String){
        loading.startAnimating()
        SKYContainer.default().auth.login(withEmail: email, password: pw) { (user, error) in
            self.loading.stopAnimating()
            guard error == nil else{
                self.presentAlert(title: "Error", message: "Wrong email or password")
                return
            }
            print("login successful")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC")
            self.present(vc!, animated: false)
        }
    }
    
    func presentAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Confirm", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        // Auto login
        if (SKYContainer.default().auth.currentUser != nil){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC")
            self.present(vc!, animated: false)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedEmail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
