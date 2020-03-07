//
//  Entity.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-02-25.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation

public protocol Entity: Codable {
    var ID: Int { get set }
}

extension Entity {

    /// The JSON Key used to index this item.   See `CodableItem`
    // We now automatically get the keyname from the instance self
    static var key: String {
        return String(describing: self)
    }
}
