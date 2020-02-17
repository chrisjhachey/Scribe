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

public class Text: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var author: String?
    var passages = List<Passage>()
    
    public init(name: String) {
        self.name = name
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        fatalError("init(value:schema:) has not been implemented")
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init()
    }
    
    required init() {
        self.name = ""
        super.init()
    }
}
