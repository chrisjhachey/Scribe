//
//  Text.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-03.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class Text: Entity {
    public var ID: Int = 0
    
    public var Name: String = ""
    public var Author: String?
    //public var Passages: [Passage]?
    
//    /// JSON Serialization Keys
//    private enum Keys: String, CodingKey {
//        case id
//        case name
//        case author
//        case passages
//    }
//
//    required public init(){}
//
//    /// Initialize from JSON Decoder
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: Keys.self)
//
//        id = try container.decode(String.self, forKey: Keys.id)
//        name = try container.decode(String.self, forKey: Keys.name)
//        author = try container.decode(String.self, forKey: Keys.author)
//        passages = try container.decode([Passage].self, forKey: Keys.passages)
//    }
//
//    /// Encode to JSON Decoder
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: Keys.self)
//
//        try container.encode(id, forKey: Keys.id)
//        try container.encode(name, forKey: Keys.name)
//        try container.encode(author, forKey: Keys.author)
//        try container.encode(passages, forKey: Keys.passages)
//    }
}
