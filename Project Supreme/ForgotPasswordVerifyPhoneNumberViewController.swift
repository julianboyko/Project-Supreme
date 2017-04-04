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
    
    var pool: AWSCognitoIdentityUserPool? // variable defined as a User Pool
    var user: AWSCognitoIdentityUser? // variable defined as a User
    
    var phoneNumber: String! // variable that holds the phone number that was passed to it from the previous view controller (ForgotPasswordViewController)
    var userName: String! // variable that holds the user name that was passed to it from the previous view controller (ForgotPasswordViewController)
    
    @IBOutlet weak var phoneNumberTextField: UITextField! // textField to enter phone number
    
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
            self.supremeShowError(title: "Hold up", message: "Please enter a phone number", action: nil)
            return
        }
        
        guard phoneNumberValue == phoneNumber else { // checks if the phone number that the user entered matches the phone number of the user that they are trying to reset the password of
            self.supremeShowError(title: "Oops", message: "The phone number you entered is incorrect", action: nil)
            return
        }
        
        // user entered the matching phone number (correct)
        self.user = self.pool?.getUser(self.userName)
        self.user?.forgotPassword().continueWith(block: {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            if let error = task.error as? NSError {
                strongSelf.supremeShowError(title: String(describing: error.userInfo["__type"]!), message: String(describing: error.userInfo["message"]!), action: nil)
            } else {
                strongSelf.supremePerformSegue(withIdentifier: "NewPasswordSegue", sender: sender)
            }
            return nil
        })
        
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
