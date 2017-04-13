//
//  SignUpViewController.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-23.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class SignUpViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField! // textField that holds the username the user enters to sign up
    @IBOutlet weak var emailTextField: UITextField! // textField that holds the email the user enters to sign up
    @IBOutlet weak var passwordTextField: UITextField! // textField that holds the password the user enters to sign up
    @IBOutlet weak var retypePasswordTextField: UITextField! // textField that holds the retyped password the user enters to sign up

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpPhoneVerify = segue.destination as? SignUpPhoneViewController {
            // transition to SignUpPhoneViewController and pass the username, password and email the user entered
            let newUser = NewUser(username: usernameTextField.text!.lowercased(),
                                  password: passwordTextField.text!,
                                  email: emailTextField.text!)
            signUpPhoneVerify.newUser = newUser
        }
    }

    @IBAction func onSignUp(_ sender: Any) {

        let checkCredentials = validCredentials()
        
        if checkCredentials.continue != true { // if the user didn't fill up each textField
            self.supremeShowError(title: "Oops", message: checkCredentials.message!, action: nil)
            return
        }
        
        let getUser = lambdaFunction >>> lambdaFunctionGetResponse
        
        DispatchQueue.global(qos: .background).async {
            let response = getUser(.getUser(username: self.usernameTextField.text!.lowercased()))
            switch response {
            case .timedOut:
                self.supremeShowError(title: "Woah that's weird", message: "Task timed out... try again in a minute", action: nil)
            case .userAlreadyExists:
                self.supremeShowError(title: "Sorry", message: "User already exists", action: nil)
            default:
                self.supremePerformSegue(withIdentifier: "PhoneVerifySegue", sender: SignUpViewController.self) // continue sign up process
            }
        }
        
    }
    
    func validCredentials() -> (continue: Bool, message: String?) {
        
        if usernameTextField.text!.isEmpty {
            return (false, "You forgot to enter a username!")
        }
        if passwordTextField.text!.isEmpty {
            return (false, "You forgot to enter a password!")
        }
        if emailTextField.text!.isEmpty {
            return (false, "You forgot to enter a email!")
        }
        if passwordTextField.text!.characters.count < 6 {
            return (false, "Your password has to be at least 6 characters long!")
        }
        if passwordTextField.text! != retypePasswordTextField.text! {
            return (false, "Your password's do not match!")
        }
        if !emailTextField.text!.contains("@") || !emailTextField.text!.contains(".") {
            return (false, "You need to enter a valid email!")
        }
        return (true, nil)
    }

}
