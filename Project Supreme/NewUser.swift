//
//  NewUser.swift
//  Project Supreme
//
//  Created by Julian Boyko on 2017-04-02.
//  Copyright © 2017 Supreme Apps. All rights reserved.
//

import UIKit

final class NewUser {
    var username: String
    var password: String
    var email: String
    
    init(username: String, password: String, email: String) {
        self.username = username
        self.password = password
        self.email = email
    }
}
