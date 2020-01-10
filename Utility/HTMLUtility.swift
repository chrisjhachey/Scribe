//
//  HTMLUtility.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-08.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import RealmSwift

public class HTMLUtility {
    
    public static func getNSAttributedString(text: Text) -> NSMutableAttributedString? {
        var content: String = ""
        
        for passage in text.passages {
            content += "<p>\"\(passage.content)\"</p>"
        }
        
        let html = """
                    <html>
                    <body>
                        <div>
                            <h1>\(text.name)</h1>
                            \(content)
                        </div>
                    </body>
                    </html>
                   """
        
        let data = Data(html.utf8)
        
        if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            return attributedString
        }
        
        return nil
    }
}
