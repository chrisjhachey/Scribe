//
//  Note.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-11.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

public class Note: Object {
    @objc dynamic var content: String = ""
    //var passage = LinkingObjects(fromType: Passage.self, property: "notes")
    
    required init() {
        super.init()
    }
 
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        fatalError("init(realm:schema:) has not been implemented")
    }
    
    required init(value: Any, schema: RLMSchema) {
        fatalError("init(value:schema:) has not been implemented")
    }
}

