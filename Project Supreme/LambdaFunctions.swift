//
//  LambdaFunctions.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-04-12.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

struct LambdaFunction {
    enum LambdaFunctionType {
        case getUser(username: String)
        case deleteUser(username: String)
    }
    
    enum LambdaFunctionResponse {
        case timedOut
        case userAlreadyExists
        case userDoesNotExist
        case userIsUnconfirmed
    }
}

func lambdaFunction(function: LambdaFunction.LambdaFunctionType) -> AWSAPIGatewayResponse {
    
    var result: AWSAPIGatewayResponse?
    
    let httpMethodName = "GET"
    var URLString = String()
    var queryStringParameters = [String : String]()
    let headerParameters = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    
    switch function {
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
    
    let invocationClient = AWSAPI_2FAM04WBZ9_LambdaGateClient(forKey: AWSCloudLogicDefaultConfigurationKey)
    invocationClient.invoke(apiRequest).continueWith { (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
        if let error = task.error {
            print("Error occurred: \(error)")
            return nil
        }
        
        result = task.result!
        
        return nil
    }.waitUntilFinished()
    return result!
}

func lambdaFunctionGetResponse(result: AWSAPIGatewayResponse) -> LambdaFunction.LambdaFunctionResponse {
    
    let lambdaResponse = LambdaFunction.LambdaFunctionResponse.self
    
    let responseData = result.responseData!
    let responseString = String(data: responseData, encoding: .utf8)
    
    if responseString! ~= awsErrorType.timedOut {
        return lambdaResponse.timedOut
    } else if responseString! == "null" {
        return lambdaResponse.userDoesNotExist
    } else {
        do {
            let object = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
            let json = JSON(object: object)
            if json["UserStatus"].string == "UNCONFIRMED" {
                return lambdaResponse.userIsUnconfirmed
            }
        } catch { print("Error parsing data") }
    }
    
    return lambdaResponse.userAlreadyExists
}
