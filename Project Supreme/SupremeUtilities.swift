//
//  SupremeUtilities.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-30.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import Foundation
import UIKit


// MARK: Constants

struct awsErrorType {
    
    static let timedOut = "errorMessage"
    
    // error codes matched to their corresponding errors
    static let unconfirmedUser = 26
    static let userAlreadyExists = 28
    static let invalidEmailAddress = 9
}


// MARK: Extensions

extension UIViewController {
    // extension to run ui actions on the main thread
    func supremeShowError(title: String, message: String, action: UIAlertAction?) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .alert)
            
            if action == nil {
                ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            } else {
                ac.addAction(action!)
            }
            
            self.present(ac, animated: true)
        }
    }
    
    func supremePerformSegue(withIdentifier: String, sender: Any?) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: withIdentifier, sender: sender)
        }
    }
    
    func supremePresent(viewController: UIViewController, animated: Bool) {
        DispatchQueue.main.async {
            self.present(viewController, animated: animated)
        }
    }
    
}

extension AWSAPI_2FAM04WBZ9_LambdaGateClient {
    // extension to run specified lambda functions without entering all their details each time (quicker)
    
    enum LambdaFunction {
        case getUser(username: String)
        case deleteUser(username: String)
    }
    
    func supremeInvoke(lambdaFunction: LambdaFunction) -> AWSTask<AWSAPIGatewayResponse> {
        
        let httpMethodName = "GET"
        var URLString = String()
        var queryStringParameters = [String : String]()
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        switch lambdaFunction {
        case .getUser(let username):
            URLString = "/getuser"
            queryStringParameters = ["username":"\(username)"]
            
        case .deleteUser(let username):
            URLString = "/deleteuser"
            queryStringParameters = ["username":"\(username)"]
            
        }
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                          urlString: URLString,
                                          queryParameters: queryStringParameters,
                                          headerParameters: headerParameters,
                                          httpBody: nil)
        
        return self.invoke(apiRequest)
    }
    
}

// MARK: Operator Overloading

func ~=(lhs: String, rhs: String) -> Bool {
    if lhs.contains(rhs) { return true } else { return false }
}
