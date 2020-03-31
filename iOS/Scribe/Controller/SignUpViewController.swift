//
//  SignUpViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-03-09.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

public class SignUpViewController: UIViewController {
    //TODO don't hard code this to true and perform real authentication
    var authenticated: Bool = false
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var retypedPassword: UITextField!
    @IBOutlet weak var loginErrorMessage: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        print("Hello")
    }
    
    @IBAction func signUp(_ sender: Any) {
        if let username = username.text, let password = password.text, let retypedPassword = retypedPassword.text {
            let usernameValid = Utility.isValidEmail(username)
            let passwordsMatch = password == retypedPassword
            
            if passwordsMatch == false {
                self.loginErrorMessage.text = "Passwords mismatch"
            } else if usernameValid == false {
                self.loginErrorMessage.text = "Username must be an email address"
            } else {
                let newUser = User(username: username, password: password)
                
                firstly { () -> Promise<[User]> in
                    ScribeAPI.shared.post(resourcePath: "user", entity: newUser)
                }.then { results -> Promise<[Token]> in
                    ScribeAPI.shared.get(resourcePath: "token?username=\(results[0].Username)&password=\(results[0].Password)")
                }.then { results -> Promise<[UsageMeasurementEntry]> in
                    self.authenticated = true
                    Context.shared.token = results[0]
                    
                    let usageEntry = UsageMeasurementEntry()
                    usageEntry.UserID = Context.shared.userId!
                    usageEntry.Action = UsageMeasurementEntry.UsageMeasurementAction.Login.rawValue
                    
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
                    let appController = storyBoard.instantiateViewController(withIdentifier: "AppRoot")
                    UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = appController
                    UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.makeKeyAndVisible()
                }.catch { error in
                    print(error)
                    self.loginErrorMessage.text = "An Error Occured During Sign Up"
                }
            }
            
        } else {
            print("All required fields must not be empty")
        }
    }
    
    @objc func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    public override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return authenticated
    }
}
