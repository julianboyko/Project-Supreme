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

    @IBOutlet weak var phoneNumberTextField: UITextField! // textField that will be used for the user to enter the phone number matched with the user they entered on the previous view controller (ForgotPasswordViewController)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey) // sets the UserPool to the pool variable
        phoneNumber = phoneNumber.substring(from: phoneNumber.index(phoneNumber.startIndex, offsetBy: 2)) // trims the "+1" from the phone number
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPasswordViewController = segue.destination as? UserPoolNewPasswordViewController {
            newPasswordViewController.user = self.user // passes the user that's password is being reset to the UserPoolNewPasswordViewController
        }
    }
    
    @IBAction func onSendSMS(_ sender: Any) {
        // this function is ran when when the user clicks the send sms button
        
        guard let phoneNumberValue = phoneNumberTextField.text, !phoneNumberValue.isEmpty else { // checks if the phone number textField is empty
            let ac = UIAlertController(title: "Hold up!", message: "Please enter a phone number", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(ac, animated: true)
            return
        }
        
        guard phoneNumberValue == phoneNumber else { // checks if the phone number that the user entered matches the phone number of the user that they are trying to reset the password of
            let ac = UIAlertController(title: "Oops", message: "The phone number you entered is incorrect", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(ac, animated: true)
            return
        }
        
        // if the phone number matches the user's phone number, begin to reset password process
        self.user = self.pool?.getUser(self.userName)
        self.user?.forgotPassword().continueWith(block: {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as? NSError {
                    // if there is an error while trying to begin the forget password process, show the user the error
                    let ac = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    ac.title = error.userInfo["__type"] as? String
                    ac.message = error.userInfo["message"] as? String
                    strongSelf.present(ac, animated: true)
                } else {
                    // if there are no errors, segue the user onto the UserPoolNewPasswordViewController 
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
