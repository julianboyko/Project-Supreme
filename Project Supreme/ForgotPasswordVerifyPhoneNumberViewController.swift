//
//  ForgotPasswordVerifyPhoneNumberViewController.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-17.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class ForgotPasswordVerifyPhoneNumberViewController: UIViewController {
    
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    
    var phoneNumber: String!
    var userName: String!

    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        phoneNumber = phoneNumber.substring(from: phoneNumber.index(phoneNumber.startIndex, offsetBy: 2)) // trims the "+1" from the phone number
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPasswordViewController = segue.destination as? UserPoolNewPasswordViewController {
            newPasswordViewController.user = self.user
        }
    }
    
    @IBAction func onSendSMS(_ sender: Any) {
        
        guard let phoneNumberValue = phoneNumberTextField.text, !phoneNumberValue.isEmpty else {
            let ac = UIAlertController(title: "Hold up!", message: "Please enter a phone number", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(ac, animated: true)
            return
        }
        
        guard phoneNumberValue == phoneNumber else {
            let ac = UIAlertController(title: "Oops", message: "The phone number you entered is incorrect", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(ac, animated: true)
            return
        }
        
        self.user = self.pool?.getUser(self.userName)
        self.user?.forgotPassword().continueWith(block: {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as? NSError {
                    let ac = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    ac.title = error.userInfo["__type"] as? String
                    ac.message = error.userInfo["message"] as? String
                    strongSelf.present(ac, animated: true)
                } else {
                    strongSelf.performSegue(withIdentifier: "NewPasswordSegue", sender: sender)
                }
            })
            return nil
        })
        
    }

    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
