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
                }.done { results in
                    self.authenticated = true
                    Context.shared.token = results[0]
                    
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
                    
                    self.performSegue(withIdentifier: "signUpSuccessfull", sender: self)
                }.catch { error in
                    print(error)
                    self.loginErrorMessage.text = "An Error Occured During Sign Up"
                }
            }
            
        } else {
            print("All required fields must not be empty")
        }
    }
    
    public override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return authenticated
    }
}
