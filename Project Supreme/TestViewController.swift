//
//  TestViewController.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-03-06.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class TestViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onCheck(_ sender: Any) {
        let serviceConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: nil)
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "2r1mgr7sil1a09amud2goato1c", clientSecret: "gqj6q1tb68bojd3al451cia37h2iaaj11tvivat23ahsnjpp3ek", poolId: "us-east-1_gr51eAvYe")
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: "UserPool")
        let pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        let _ = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:e41bf209-4073-405e-8114-0bd6915db3de", identityProviderManager:pool)
        
        /*if pool.getUser(username.text!).getDetails().isFaulted {
            print("nah")
        } else {
            print ("ya'")
        }*/
        
        pool.getUser(username.text!).getDetails().continueWith(block: { (task: AWSTask) -> Any? in
            if let error = task.error as? NSError {
                if let type = error.userInfo["__type"] as? String {
                    if type == "UserNotFoundException" {
                        print ("user not found")
                    }
                }
            }
            return nil
        })

        /*if pool.getUser(username.text!).getDetails().error != nil {
            print("ya")
        } else {
            print("na")
        }*/
    }

}
