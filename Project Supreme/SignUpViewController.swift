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
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var didSignInObserver: AnyObject!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.addTarget(self, action: Selector(("handleCustomSignIn")), for: .touchUpInside)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpPhoneVerify = segue.destination as? UserPoolSignUpViewController {
            signUpPhoneVerify.userName = usernameTextField.text!.lowercased()
            signUpPhoneVerify.email = emailTextField.text!
            signUpPhoneVerify.password = passwordTextField.text!
        }
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


