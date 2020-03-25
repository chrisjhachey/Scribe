//
//  Token.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-03-14.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation

public class Token: Entity {
    public var ID: Int = 0
    
    public var Token: String
    public var Expirey: String
    public var Valid: Bool
    
    public init(token: String, expirey: String) {
        self.Token = token
        self.Expirey = expirey
        self.Valid = true
    }
}
