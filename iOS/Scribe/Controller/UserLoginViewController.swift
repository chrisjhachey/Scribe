//
//  UserLoginViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-03-09.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

public class UserLoginViewController: UIViewController {
    var authenticated: Bool = false
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginErrorMessage: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func login(_ sender: Any) {
        let user = User(username: username.text!, password: password.text!)
        
        firstly { () -> Promise<[Token]> in
            ScribeAPI.shared.get(resourcePath: "token?username=\(user.Username)&password=\(user.Password)")
        }.then { results -> Promise<[UsageMeasurementEntry]> in
            self.authenticated = true
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
            
            let defaults = UserDefaults.standard
            defaults.set(user.Username, forKey: "username")
            defaults.set(user.Password, forKey: "password")

            self.performSegue(withIdentifier: "loginSuccessfull", sender: self)
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let appController = storyBoard.instantiateViewController(withIdentifier: "AppRoot")
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = appController
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.makeKeyAndVisible()
        }.catch { error in
            print(error)
            self.loginErrorMessage.text = "Please check your username and password."
        }
    }
    
    public override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return authenticated
    }
}
