//
//  ScribeAPI.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-02-18.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import PromiseKit

public struct ScribeAPI {
    // Singleton
    public static let shared = ScribeAPI()
    
    // Defines the base URL for the API
    let baseURL = "http://localhost:5000/api/v1/"
    
    // Generic retrieve resource function
    func get<T: Entity>(resourcePath: String) -> Promise<[T]> {
        let urlString = baseURL + resourcePath
        let url = URL(string: urlString)
        let httpVerb = "GET"
        
        return Promise { seal in
            firstly {
                performRequest(url: url!, verb: httpVerb, data: nil)
            }.done { results in
                seal.fulfill(self.makeModel(jsonData: results.data))
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func delete(resourcePath: String) -> Promise<String> {
        let urlString = baseURL + resourcePath
        let url = URL(string: urlString)
        let httpVerb = "DELETE"
        
        return Promise { seal in
            firstly {
                performRequest(url: url!, verb: httpVerb, data: nil)
            }.done { results in
                seal.fulfill("Delete Successfull!")
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func post<T: Entity>(resourcePath: String, entity: T) -> Promise<[T]> {
        
        let urlString = baseURL + resourcePath
        let url = URL(string: urlString)
        let httpVerb = "POST"
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(entity)
        
        print("JSON passed to request body: \(String(decoding: data, as: UTF8.self))")
        
        return Promise { seal in
            firstly {
                performRequest(url: url!, verb: httpVerb, data: data)
            }.done { results in
                seal.fulfill(self.makeModel(jsonData: results.data))
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    // Performs a Network Request
    func performRequest(url: URL, verb: String?, data: Data?) -> Promise<NetworkResponse> {
        
        // Define the headers for this request
        var headerDictionary: [String: String] = [ "Accept": "application/json", "Accept-Encoding": "gzip" ]
        
        if let token = Context.shared.token {
            headerDictionary["Scribe-Token"] =  "\(token.Token)"
        }
        
        // Create a request from the URL
        var request = URLRequest(url: url)
        
        if let verb = verb {
            request.httpMethod = verb
        }
        
        // If there is a JSON body add it to the Request
        if let data = data {
            request.httpBody = data
        }
        
        // Add Headers to the Request
        addRequestHeaders(request: &request, headers: headerDictionary)
        
        // Create response object
        let response = NetworkResponse()
        
        return Promise { seal in
            firstly {
                URLSession.shared.dataTask(.promise, with: request).validate()
            }.done { results in
                let str = String(decoding: results.data, as: UTF8.self)
                print(str)
                
                response.data = results.data
                response.url = request.url!.absoluteString
                response.contentType = results.response.mimeType!
                
                if let urlResponse = results.response as? HTTPURLResponse {
                    if let userId = urlResponse.allHeaderFields["Userid"] as? String {
                        Context.shared.userId = Int(userId)
                    }
                }
                
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    // Deserializes JSON into Swift Models
    func makeModel<T: Entity>(jsonData: Data) -> [T] {
        var entities = [T]()
        let decoder = JSONDecoder()
        
        do {
            entities = try decoder.decode([T].self, from: jsonData)
        } catch {
            print(error)
        }
        
        return entities
    }
    
    // Adds a dictionary of headers to a URLRequest
    private func addRequestHeaders(request: inout URLRequest, headers: [String: String] = [:]) {
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
