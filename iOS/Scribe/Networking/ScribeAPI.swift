//
//  ScribeAPI.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-02-18.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation

public struct ScribeAPI {
    let baseURL = "http://www.localhost:8080/api/v1/"
    
    func getTexts() {
        let urlString = baseURL + "text"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            task.resume()
        }
    }
    
    func handle(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            print(error!)
            return
        }
        
        if let safeData = data {
            let dataString = String(data: safeData, encoding: .utf8)
            print(dataString)
            print("Hachey")
        }
    }
}
