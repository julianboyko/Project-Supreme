//
//  TestViewController.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-15.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSAPIGateway

class TestViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapped(_ sender: Any) {
        let httpMethodName = "GET"
        let URLString = "/getuser"
        let queryStringParameters = ["username":"\(textField.text!)"]
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
            
            var phoneNumber = String()
            for i in attributes {
                if i.contains("phone_number=") {
                    phoneNumber = i
                    phoneNumber = phoneNumber.replacingOccurrences(of: "phone_number=", with: "")
                }
            }

            print(phoneNumber)
            
            return nil
        }
    }
}
