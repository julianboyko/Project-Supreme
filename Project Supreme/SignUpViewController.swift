//
//  SignUpViewController.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-07.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class SignUpViewController: UIViewController {
    
    // This class serves an important purpose. This class doesn't actually do any of the Signing Up of a new user. Instead this class uses the AWS Cognito Login features to check if the username that the new user wants to use for their account is already taken by an existing user. This class is closely tied/connected with the SignUpViewController extensions class to help with the login process. The SignUpViewControllerExtensions class also checks to make sure that the email the new user enters is valid & the passwords the new user enters match each other. 
    
    @IBOutlet weak var usernameTextField: UITextField! // textField where a new user enters his/her wanted username
    @IBOutlet weak var passwordTextField: UITextField! // textField where a new user enters his/her password
    @IBOutlet weak var retypePasswordTextField: UITextField! // textField where a new user re-enters his/her password
    @IBOutlet weak var emailTextField: UITextField! // textField where a new user enters his/her email address
    
    @IBOutlet weak var signUpButton: UIButton! // uibutton that is clicked to start the sign up process
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>? // used to attempt to sign in the user with the username provided by the new user. this is to see if the username is already taken before beggining the actual sign up process
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.addTarget(self, action: Selector(("handleCustomSignIn")), for: .touchUpInside) // attaches a function in the "SignUpViewControllerExtensions" to attempt to Sign In the user with the credentials provided by the new user to see if the username the new user wants is already taken by an existing user
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if the username is not already taken and there is no issues with the credentials provided by the new user, segue them onto the UserPoolSignUpViewController where the real sign up process begins
        if let signUpPhoneVerify = segue.destination as? UserPoolSignUpViewController {
            signUpPhoneVerify.userName = usernameTextField.text!.lowercased() // passes the username entered into the username variable on the next view controller
            signUpPhoneVerify.email = emailTextField.text! // passes the email entered into the email variable on the next view controller
            signUpPhoneVerify.password = passwordTextField.text! // passes the password entered into the passsword variable on the next view controller 
        }
    }
    
    func handleLoginWithSignInProvider(_ signInProvider: AWSSignInProvider) {
        // this function is called from the SignUpViewControllerExtensions after the signup uibutton is clicked. this begins the process of checking if the username is already taken by an existing user
        AWSIdentityManager.default().login(signInProvider: signInProvider, completionHandler:
            {(result: Any?, error: Error?) -> Void in
                if error == nil {
                    /* Handle successful login. */
                }
                print("Login with signin provider result = \(result), error = \(error)")
        })
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}


