//
//  Context.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-03.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation

public class Context {
    public var workingText: Text?
    public var userId: Int?
    public var token: Token?
    
    // Single shared instance (Singleton)
    public static let shared = Context()
}
