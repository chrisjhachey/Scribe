//
//  RealmUtility.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-16.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import RealmSwift
import Realm

protocol CascadeDeleting {
    func delete<T: Object>(_ entity: T, cascading: Bool)
}

extension Realm: CascadeDeleting {
    func delete<T: Object>(_ entity: T, cascading: Bool) {
        if cascading {
            cascadeDelete(entity)
        } else {
            delete(entity)
        }
    }
}

private extension Realm {
    
    private func cascadeDelete(_ entity: RLMObjectBase) {
        guard let entity = entity as? Object else { return }
        var toBeDeleted = Set<RLMObjectBase>()
        toBeDeleted.insert(entity)
        while !toBeDeleted.isEmpty {
            guard let element = toBeDeleted.removeFirst() as? Object,
                !element.isInvalidated else { continue }
            resolve(element: element, toBeDeleted: &toBeDeleted)
        }
    }

    private func resolve(element: Object, toBeDeleted: inout Set<RLMObjectBase>) {
        element.objectSchema.properties.forEach {
            guard let value = element.value(forKey: $0.name) else { return }
            if let entity = value as? RLMObjectBase {
                toBeDeleted.insert(entity)
            } else if let list = value as? RealmSwift.ListBase {
                for index in 0..<list._rlmArray.count {
                    toBeDeleted.insert(list._rlmArray.object(at: index) as! RLMObjectBase)
                }
            }
        }
        delete(element)
    }
}
