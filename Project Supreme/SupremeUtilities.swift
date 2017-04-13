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

// MARK: Operator Overloading

func ~=(lhs: String, rhs: String) -> Bool {
    if lhs.contains(rhs) { return true } else { return false }
}

//////////////////////////////////////////////
// function composition
precedencegroup CompositionPrecedence {
    associativity: left
}

infix operator >>>: CompositionPrecedence

func >>> <T, U, V>(lhs: @escaping (T) -> U, rhs: @escaping (U) -> V) -> (T) -> V {
    return { rhs(lhs($0)) }
}
//////////////////////////////////////////////
