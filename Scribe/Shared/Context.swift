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
    public var username = "Christopher Hachey"
    public var blinkLicenseKey = "sRwAAAEcY29tLmNocmlzdG9waGVyaGFjaGV5LnNjcmliZSDyYFNyG71rHQm7htdcTrWTT2XEAkwqCAGF2G/tXk3auD9ZgGG3FHf7iHSmnD2ZycSVt5RgfC/DV4BJUYaJiqcJC5moJwnlR1O+GXvBVJeKiNGhUP2aarB6fHP5HPv1Z2G+HI18xFxb+BjRGUCiVxTFlzzN2owkIP0M5mzUVPRlH3MWpqr9hXDRwosf2aI="
    
    // Single shared instance (Singleton)
    public static let shared = Context()
}
