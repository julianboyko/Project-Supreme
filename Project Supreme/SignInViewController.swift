//
//  SignInViewController.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-06.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField! // textField where the user enters his/her username
    @IBOutlet weak var passwordTextField: UITextField! // textField where the user enters his/her password
    
    @IBOutlet weak var loginButton: UIButton! // uibutton that is clicked to activate the login
    @IBOutlet weak var createAccountButton: UIButton! // uibutton that is clicked to go to the create account screen
    @IBOutlet weak var forgotPassword: UIButton! // uibutton that is clicked to go to the forgot password screen
    
    var didSignInObserver: AnyObject! // observer that is later attached to the notification center to check if the user is already logged in
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    
    var pool: AWSCognitoIdentityUserPool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Sign In Loading.")
        
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        // checks if the user is already logged in
        didSignInObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.default(), queue: OperationQueue.main, using: {(note: Notification) -> Void in
            // perform successful login actions here
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpConfirmation") as! UserPoolSignUpConfirmationViewController
            self.present(vc, animated: true)
        })
        loginButton.addTarget(self, action: Selector(("handleCustomSignIn")), for: .touchUpInside)
        createAccountButton.addTarget(self, action: Selector(("handleUserPoolSignUp")), for: .touchUpInside)
        forgotPassword.addTarget(self, action: Selector(("handleUserPoolForgotPassword")), for: .touchUpInside)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(didSignInObserver) // if the user isn't logged in, remove the observer
    }
    
    func handleLoginWithSignInProvider(_ signInProvider: AWSSignInProvider) {
        AWSIdentityManager.default().login(signInProvider: signInProvider, completionHandler:
            {(result: Any?, error: Error?) -> Void in
                if error == nil {
                    /* Handle successful login. */
                }
                print("Login with signin provider result = \(result), error = \(error)")
        })
    }

}

