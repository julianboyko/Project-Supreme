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
            forgotPasswordVerifyPhoneNumberVC.phoneNumber = self.userPhoneNumber // passes the phoneNumber that was aquired from the user that was entered in the textField to the userPhoneNumber variable on the ForgotPasswordVerifyPhoneNumberViewController
            forgotPasswordVerifyPhoneNumberVC.userName = self.userNameTextField.text!.lowercased() // passes the userName entered in the userNameTextField to the userName variable on the ForgotPasswordVerifyPhoneNumberViewController. The userNameTextField is put to lowercased because all users in the UserPool are lowercased
        }
    }
    
    @IBAction func onForgotPassword(_ sender: Any) {
        // this function is ran when the ForgotPassword button is clicked
        
        guard let userName = self.userNameTextField.text, !userName.isEmpty else { // if the user never entered a username, tell the user that
            let ac = UIAlertController(title: "Hold up!", message: "Please enter your username!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(ac, animated: true)
            return
        }
        
        // attempt to get the user attributes for the user entered in the textField 
        
        let httpMethodName = "GET" // the lambda function receives a "GET" method to aquire the user attributes
        let URLString = "/getuser" // the url string on the lambda function is /getuser
        let queryStringParameters = ["username":"\(userNameTextField.text!.lowercased())"] // the paramaters for the lambda function is the username of the user, so this gives the paramater the username entered in the userNameTextField and sets it to lowercased.. it's lowercased because.. you know why 
        
        // the lamba function accepts information as json and returns information as json
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: nil)
        
        // Fetch the Cloud Logic client to be used for invocation
        // Change the `AWSAPI_XE21FG_MyCloudLogicClient` class name to the client class for your generated SDK
        let invocationClient = AWSAPI_2FAM04WBZ9_LambdaGateClient(forKey: AWSCloudLogicDefaultConfigurationKey)
        
        // run the lambda function with the apiRequest
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            //guard let strongSelf = self else { return nil }
            
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return nil
            }
            
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8) // put the result's responseData in a String to do some error checks
            
            // check if the user does not exist. (if the responseString comes out as "null" that means that the lambda function couldn't find the user associated with the username entered.. meaning it doesn't exist.)
            if responseString! == "null" {
                DispatchQueue.main.async(execute: {
                    let ac = UIAlertController(title: "Oops", message: "The user you entered does not exist!", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    self.present(ac, animated: true)
                })
                return nil
            }
            
            // check if the responseString contains the text "errorMessage" because when the lambda function time runs for longer than the Timeout time set in the Lambda Console, the function times out and stops running.
            if responseString!.contains("errorMessage") {
                print("Task timed out.. took longer than 10 seconds.")
                // send an error back to the user. this means that the user can't connect to the lambda function within the 10 seconds. maybe their connection is off?
                return nil
            }
            
            // if the user does exist and the lambda function didn't time out or have any errors, run the following:
            do {
                let object = try JSONSerialization.jsonObject(with: result.responseData!, options: .allowFragments) // set the responseData to a jsonObject
                if let dictionary = object as? [String: AnyObject] { // set the object to a dictionary with the type [String: AnyObject]
                    self.readJSONObject(object: dictionary) // run the readJSONObject function and pass in the dictionary made through the responseData
                    
                    for case let attr in self.userAttributes where JSON(object: attr)["Name"].string == "phone_number" {
                        self.userPhoneNumber = JSON(object: attr)["Value"].string!
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "VerifyPhoneNumber", sender: sender) // perform a segue onto the next view controller which is the "ForgotPasswordVerifyPhoneNumberViewController" on the main thread
                    })
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
