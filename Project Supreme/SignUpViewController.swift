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
        
        getUser(username: usernameTextField.text!.lowercased())
        
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
    
    
    func getUser(username: String) {
        // check if the user is taken or unconfirmed
        
        let invocationClient = AWSAPI_2FAM04WBZ9_LambdaGateClient(forKey: AWSCloudLogicDefaultConfigurationKey)
        
        invocationClient.supremeInvoke(lambdaFunction: .getUser(username: username)).continueWith { (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            if let error = task.error {
                print ("Error occurred: \(error)")
                return nil
            }
            
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            
            if responseString!.contains("errorMessage") {
                // if lambda function has been running for it's entire "Timeout" time (task times out)
                self.supremeShowError(title: "Woah that's weird...", message: "Task timed out... make sure you have a strong connection", action: nil)
                
            } else if responseString! == "null" || self.userIsUnconfirmed(data: result.responseData!) {
                // if the user isn't already taken, or the user is unconfirmed
                self.supremePerformSegue(withIdentifier: "PhoneVerifySegue", sender: SignUpViewController.self) // continue sign up process
            } else {
                // user is taken and is confirmed
                self.supremeShowError(title: "Sorry", message: "User already exists!", action: nil)
            }
            
            return nil
        }
    }
    
    func userIsUnconfirmed(data: Data) -> Bool {
        // read the result.responseData to see if the user is unconfirmed, by reading it's JSON
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            let json = JSON(object: object)
            if json["UserStatus"].string == "UNCONFIRMED" {
                return true
            }
        } catch {
            print("Error parsing data")
        }
        return false
    }

}
