//
//  SignUpExtension.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-07.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import AWSMobileHubHelper

// Extension containing methods which call different operations on Cognito User Pools (Sign In, Sign Up, Forgot Password)
extension SignUpViewController {
    
    func handleCustomSignIn() {
        // set the interactive auth delegate to self, since this view controller handles the login process for user pools
        AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
        self.handleLoginWithSignInProvider(AWSCognitoUserPoolsSignInProvider.sharedInstance())
    }
}

// Extension to adopt the `AWSCognitoIdentityInteractiveAuthenticationDelegate` protocol
extension SignUpViewController: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    // this function handles the UI setup for initial login screen, in our case, since we are already on the login screen, we just return the View Controller instance
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        return self
    }
}

// Extension to adopt the `AWSCognitoIdentityPasswordAuthentication` protocol
extension SignUpViewController: AWSCognitoIdentityPasswordAuthentication {
    
    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource as? AWSTaskCompletionSource<AnyObject>
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        if let error = error as? NSError {
            DispatchQueue.main.async(execute: {
                
                let ac = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "Ok", style: .cancel)
                ac.addAction(okButton)
                ac.title = "Oops"
                
                // Check if the user exists by "logging in" then if they don't. Continue to Sign up the user.
                if error.userInfo["__type"] as? String == "UserNotFoundException" {
                    if self.passwordTextField.text!.characters.count < 6 {
                        ac.message = "Password must be 6 characters or longer!"
                        self.present(ac, animated: true)
                        return
                    }
                    if self.passwordTextField.text! != self.retypePasswordTextField.text! {
                        ac.message = "Your password's do not match!"
                        self.present(ac, animated: true)
                        return
                    }
                    if self.emailTextField.text!.isEmpty || !self.emailTextField.text!.contains("@") || !self.emailTextField.text!.contains(".") {
                        ac.message = "Please enter a valid email address"
                        self.present(ac, animated: true)
                        return
                    }
                    self.performSegue(withIdentifier: "PhoneVerifySegue", sender: SignUpViewController.self)
                    return
                }
                //

                ac.title = "Sorry!"
                ac.message = "\(self.usernameTextField.text!) is taken!"
                
                self.present(ac, animated: true)
            })
        }
    }
}

// Extension to adopt the `AWSCognitoUserPoolsSignInHandler` protocol
extension SignUpViewController: AWSCognitoUserPoolsSignInHandler {
    func handleUserPoolSignInFlowStart() {
        // check if both username and password fields are provided
        guard let username = self.usernameTextField.text, !username.isEmpty,
            let password = self.passwordTextField.text, !password.isEmpty else {
                DispatchQueue.main.async(execute: {
                    let ac = UIAlertController(title: "Missing Username / Password",
                                               message: "Please enter a valid user name / password.",
                                               preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    self.present(ac, animated: true)
                })
                return
        }
        // set the task completion result as an object of AWSCognitoIdentityPasswordAuthenticationDetails with username and password that the app user provides
        
        /*Entering a random UUID string into the password parameter so that during the Sign Up phase a user cannot accidentely enter a User that already exists and the
        password that goes with that user. This prevents logging in a user during the Sign Up Phase, because I use the AWS Login functions to check if a user already
        exists.*/
        self.passwordAuthenticationCompletion?.set(result: AWSCognitoIdentityPasswordAuthenticationDetails(username: username.lowercased(), password: UUID().uuidString))
    }
}
