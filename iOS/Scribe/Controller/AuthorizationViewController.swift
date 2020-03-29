  
//
//  AuthorizationViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-03-18.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//
import Foundation
import UIKit
import PromiseKit

public class AuthorizationViewController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let username = defaults.string(forKey: "username"), let password = defaults.string(forKey: "password") {
            firstly { () -> Promise<[Token]> in
                ScribeAPI.shared.get(resourcePath: "token?username=\(username)&password=\(password)")
            }.then { results -> Promise<[UsageMeasurementEntry]> in
                print("New Token: \(results[0].Token)")
                Context.shared.token = results[0]
                
                let usageEntry = UsageMeasurementEntry()
                usageEntry.UserID = Context.shared.userId!
                usageEntry.Action = UsageMeasurementEntry.UsageMeasurementAction.Login.rawValue
                usageEntry.DateStamp = Utility.printTimestamp()
                
                return ScribeAPI.shared.post(resourcePath: "usage", entity: usageEntry)
            }.done { results in

                // Requests a refresh token from server every 4.5 minutes
                Timer.scheduledTimer(withTimeInterval: 271, repeats: true) { timer in
                    firstly { () -> Promise<[Token]> in
                        ScribeAPI.shared.post(resourcePath: "refresh", entity: Context.shared.token!)
                    }.done { results in
                        print("New Token: \(results[0].Token)")
                        Context.shared.token = results[0]
                    }.catch { error in
                        print(error)
                    }
                }
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyBoard.instantiateViewController(withIdentifier: "AppRoot")
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = tabBarController
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.makeKeyAndVisible()
            }.catch { error in
                print(error)
                //self.loginErrorMessage.text = "Please check your username and password."
            }
        }
    }
}
