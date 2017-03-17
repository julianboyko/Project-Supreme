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
    
    @IBOutlet weak var userNameTextField: UITextField!
    var userPhoneNumber = String()
    var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userName != nil {
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
            let ac = UIAlertController(title: "Hold up!", message: "Please enter your username!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(ac, animated: true)
            return
        }
        
        
        let httpMethodName = "GET"
        let URLString = "/getuser"
        let queryStringParameters = ["username":"\(userNameTextField.text!.lowercased())"]
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
        
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            //guard let strongSelf = self else { return nil }
            
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return nil
            }
            
            // Handle successful result here
            let result = task.result!
            var responseString = String(data: result.responseData!, encoding: .utf8)
            
            // check if the user does not exist
            if responseString! == "null" {
                DispatchQueue.main.async(execute: { 
                    let ac = UIAlertController(title: "Oops", message: "The user you entered does not exist!", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    self.present(ac, animated: true)
                })
                return nil
            }
            
            responseString! = responseString!.replacingOccurrences(
                of: ":", with: "=").replacingOccurrences(
                    of: "\"", with: "").replacingOccurrences(
                        of: "Name=", with: "").replacingOccurrences(
                            of: "Value=", with: "").replacingOccurrences(
                                of: "},{", with: "}{").replacingOccurrences(
                                    of: ",", with: "=").replacingOccurrences(
                                        of: "[", with: "").replacingOccurrences(
                                            of: "]", with: "")
            
            var attributes = [String]()
            var attribute = String()
            for c in responseString!.characters {
                if c == "}" {
                    attributes.append(attribute)
                    attribute = ""
                } else if c != "{" {
                    attribute.append(c)
                }
            }
            
            for i in attributes {
                if i.contains("phone_number=") {
                    self.userPhoneNumber = i
                    self.userPhoneNumber = self.userPhoneNumber.replacingOccurrences(of: "phone_number=", with: "")
                }
            }
            
            DispatchQueue.main.async(execute: { 
                self.performSegue(withIdentifier: "VerifyPhoneNumber", sender: sender)
            })
            return nil
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
