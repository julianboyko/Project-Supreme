//
//  SignUpViewController.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-23.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class SignUpViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpPhoneVerify = segue.destination as? SignUpPhoneViewController {
            signUpPhoneVerify.newUserInfo.username = usernameTextField.text!.lowercased()
            signUpPhoneVerify.newUserInfo.password = passwordTextField.text!
            signUpPhoneVerify.newUserInfo.email = emailTextField.text!
        }
    }

    @IBAction func onSignUp(_ sender: Any) {
        
        let checkCredentials = validCredentials()
        if checkCredentials != "valid" {
            DispatchQueue.main.async(execute: {
                let ac = UIAlertController(title: "Oops", message: checkCredentials, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self.present(ac, animated: true)
            })
            return
        }
        
        getUser(username: usernameTextField.text!.lowercased())
        
    }
    
    func validCredentials() -> String {
        var message = String()
        
        if usernameTextField.text!.isEmpty {
            message = "You forgot to enter a username!"
            return message
        }
        if passwordTextField.text!.isEmpty {
            message = "You forgot to enter a password!"
            return message
        }
        if emailTextField.text!.isEmpty {
            message = "You forgot to enter a email!"
            return message
        }
        if passwordTextField.text!.characters.count < 6 {
            message = "Your password has to be at least 6 characters long!"
            return message
        }
        if passwordTextField.text! != retypePasswordTextField.text! {
            message = "Your password's do not match!"
            return message
        }
        if !emailTextField.text!.contains("@") || !emailTextField.text!.contains(".") {
            message = "You need to enter a valid email!"
            return message
        }
        return "valid"
    }
    
    
    // MARK: APIGateway & Lambda Functions
    
    func getUser(username: String) {
        
        let httpMethodName = "GET"
        let URLString = "/getuser"
        let queryStringParameters = ["username":"\(username)"]
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: nil)
        
        let invocationClient = AWSAPI_2FAM04WBZ9_LambdaGateClient(forKey: AWSCloudLogicDefaultConfigurationKey)
        
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            if let error = task.error {
                print ("Error occurred: \(error)")
                return nil
            }
            
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            
            if responseString!.contains("errorMessage") {
                print ("Task timed out..")
                DispatchQueue.main.async(execute: {
                    let ac = UIAlertController(title: "Woah that's weird..", message: "Task timed out.. make sure you have a strong connection", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    self.present(ac, animated: true)
                    return
                })
                return nil
            } else if responseString! == "null" {
                print ("User does not exist")
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "PhoneVerifySegue", sender: SignUpViewController.self)
                })
                return nil
            }
            
            do {
                let object = try JSONSerialization.jsonObject(with: result.responseData!, options: .allowFragments)
                let json = JSON(object: object)
                if json["UserStatus"].string == "UNCONFIRMED" {
                    self.terminateUser(username: username)
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "PhoneVerifySegue", sender: SignUpViewController.self)
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        let ac = UIAlertController(title: "Sorry", message: "User already exists!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                        self.present(ac, animated: true)
                        return
                    })
                }
            } catch {
                print("Error parsing data")
            }
            
            return nil
        }
    }
    
    func terminateUser(username: String) {
        let httpMethodName = "GET"
        let URLString = "/deleteuser"
        let queryStringParameters = ["username":"\(username)"]
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: nil)
        
        let invocationClient = AWSAPI_2FAM04WBZ9_LambdaGateClient(forKey: AWSCloudLogicDefaultConfigurationKey)
        
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            
            if let error = task.error {
                print ("Error occurred: \(error)")
                return nil
            }
            
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            
            print(responseString!)
            
            return nil
        }
    }

}
