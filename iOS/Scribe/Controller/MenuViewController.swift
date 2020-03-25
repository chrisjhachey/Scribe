
//
//  MenuViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-03-18.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

public class MenuViewController: UIViewController {
    
    @IBAction func export(_ sender: Any) {
        
        if let vc = self.parent as? ContainerViewController {
            vc.presentActionSheet()
        }
    }
    @IBAction func logout(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "username")
        defaults.set(nil, forKey: "password")
        defaults.set(nil, forKey: "workingText")
        GIDSignIn.sharedInstance().signOut()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let authController = storyBoard.instantiateViewController(withIdentifier: "AuthRoot")
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = authController
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.makeKeyAndVisible()
    }
}
