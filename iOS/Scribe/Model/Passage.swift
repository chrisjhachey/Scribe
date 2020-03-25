//
//  Passage.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-03.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

public class Passage: Entity, Equatable {
    public var ID: Int = 0
    
    public var UserID: Int = 0
    public var TextID: Int = 0
    public var Content: String = ""
    //var notes = List<Note>()
    
    
    // TODO: Remove, For some reason needed to add this to i could add PAssages onto stack view
    public static func == (lhs: Passage, rhs: Passage) -> Bool {
        return true
    }
}
