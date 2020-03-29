//
//  UsageMeasurementEntry.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-03-29.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation

public class UsageMeasurementEntry: Entity {
    public var ID: Int = 0
    
    public var UserID: Int = 0
    public var Action: String = ""
    public var DateStamp: String = ""
    
    public enum UsageMeasurementAction: String {
        case Login
        case Scribe
    }
}
