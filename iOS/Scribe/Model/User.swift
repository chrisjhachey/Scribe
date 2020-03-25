//
//  User.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-03-07.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation

public class User: Entity {
    public var ID: Int = 0
    
    public var Username: String
    public var Password: String
    
    public init(username: String, password: String) {
        self.Username = username
        self.Password = password
    }
}
