//
//  ForgotPasswordViewController.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-17.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class ForgotPasswordViewController: UIViewController {
    
    var userAttributes = [[String: AnyObject]]() // array of dictionaries that hold the user's user attributes that are given to you through a Lambda Function, which is run by APIGateway
    
    @IBOutlet weak var userNameTextField: UITextField! // textField where the user enters the username that they want to reset the password for
    var userPhoneNumber = String() // initialized variable that will hold the phone number of the user entered in the textField later on in the code
    var userName: String? // this variable is set on the SignInViewController, if a user enters a username in the sign in screen, and then clicks the forgot password button while still having text in the signin username textfield, then the text in that textfield will be put into this variable

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userName != nil { // if the username variable is not nil, then set the userNameTextField text to the value in the userName variable
            userNameTextField.text = userName!
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let forgotPasswordVerifyPhoneNumberVC = segue.destination as? ForgotPasswordVerifyPhoneNumberViewController {
            forgotPasswordVerifyPhoneNumberVC.phoneNumber = self.userPhoneNumber
            forgotPasswordVerifyPhoneNumberVC.userName = self.userNameTextField.text!.lowercased()
        }
    }
    
    @IBAction func onForgotPassword(_ sender: Any) {
        
        guard let userName = self.userNameTextField.text, !userName.isEmpty else {
            self.supremeShowError(title: "Hold up", message: "Please enter your username!", action: nil)
            return
        }
        
        // attempt to get the user attributes for the user entered in the textField
        let invocationClient = AWSAPI_2FAM04WBZ9_LambdaGateClient(forKey: AWSCloudLogicDefaultConfigurationKey)
        
        invocationClient.supremeInvoke(lambdaFunction: .getUser(username: userNameTextField.text!.lowercased())).continueWith { (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return nil
            }
            
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8) // put the result's responseData in a String to do some error checks
            
            // user does not exist
            if responseString! == "null" {
                self.supremeShowError(title: "Oops", message: "The user you entered does not exist!", action: nil)
                return nil
            }
            
            // if lambda function has been running for it's entire "Timeout" time (task times out)
            if responseString! ~= awsErrorType.timedOut {
                self.supremeShowError(title: "Woah that's weird...", message: "Task timed out... make sure you have a strong connection", action: nil)
                return nil
            }
            
            // get the phone number of the user entered
            do {
                let object = try JSONSerialization.jsonObject(with: result.responseData!, options: .allowFragments)
                if let dictionary = object as? [String: AnyObject] {
                    self.readJSONObject(object: dictionary)
                    
                    for case let attr in self.userAttributes where JSON(object: attr)["Name"].string == "phone_number" {
                        self.userPhoneNumber = JSON(object: attr)["Value"].string!
                    }
                    
                    self.supremePerformSegue(withIdentifier: "VerifyPhoneNumber", sender: sender)
                }
                
            } catch {
                // error parsing the json
                print("Error parsing data")
            }
            return nil
        }
    }
    
    func readJSONObject(object: [String: AnyObject]) {
        // this function reads the json dictionary passed to it
        userAttributes = object["UserAttributes"] as! [[String: AnyObject]] // sets the userAttributes variable to the values under the "UserAttributes" part of the JSON as a array of dictionaries. also having this line of code run at the beggining of this function is important because it resets the values of the userAttributes incase the user enteres a new username in the textField.
        for (index, attribute) in userAttributes.enumerated() { // loops through the userAttributes array. we track what iteration we are on in the loop and the attribute we are currently on in the loop
            guard let name = attribute["Name"] as? String,
                let value = attribute["Value"] as? String else { break } // sets the variable name to the attributes "Name" value as a String and sets the variable value to the attributes "Value" value as a String
            let obj = ["Name": name, "Value": value] // creates an object with the Name first and the Value second. It sets the the name value to "Name", and it sets the value value to "Value"
            userAttributes[index] = obj as [String : AnyObject] // because the userAttributes array is already filled with attributes, we want to set the attribute we are currently on in the loop to the new object we have just created, opposed to appending it (which would create duplicates of the attributes)
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
