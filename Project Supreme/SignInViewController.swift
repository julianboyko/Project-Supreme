//
//  SignInViewController.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-06.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var forgotPassword: UIButton!
    
    var didSignInObserver: AnyObject!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Sign In Loading.")
        
        didSignInObserver =  NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.default(), queue: OperationQueue.main, using: {(note: Notification) -> Void in
            // perform successful login actions here
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpConfirmation") as! UserPoolSignUpConfirmationViewController
            
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "test") as! TestViewController
            self.present(vc, animated: true)
        })
        
        loginButton.addTarget(self, action: Selector(("handleCustomSignIn")), for: .touchUpInside)
        createAccountButton.addTarget(self, action: Selector(("handleUserPoolSignUp")), for: .touchUpInside)
        forgotPassword.addTarget(self, action: Selector(("handleUserPoolForgotPassword")), for: .touchUpInside)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(didSignInObserver)
    }
    
    func getUserIdentity() -> String {
        return AWSIdentityManager.default().identityId!
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

