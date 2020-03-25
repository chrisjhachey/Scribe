//
//  AppDelegate.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-01.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    public static var window: UIWindow?
    public static let googleDriveService = GTLRDriveService()
    public static var googleUser: GIDGoogleUser?
    public static var uploadFolderID: String?
    public static var appRootDelegate: ContainerViewController?
    public static var signedIntoGoogleInApp: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let defaults = UserDefaults.standard
        let testDataLoaded = defaults.bool(forKey: "testDataLoaded")
        defaults.set(false, forKey: "googleSignIn")
        
        // Initialize Google sign-in
        GIDSignIn.sharedInstance()?.clientID = "431769686759-6pa2d6l14a6scsoj52n4l37a57e63f09.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive]
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()                      // Automatically sign in the user.
        
        // Gives us the directory for the userDefaults plist
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        
        if testDataLoaded == false {
            let sampleData = SampleData()
            sampleData.generateSampleData()
        }

        return true
    }
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("Application will terminate!")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Application did enter background!")
    }
    
    
    // Google sign in methods
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            
            AppDelegate.googleDriveService.authorizer = nil
            AppDelegate.googleUser = nil
            return
        }
        
        // Perform any operations on signed in user here.
        print("Signed Into Google!")
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "googleSignIn")
        
        AppDelegate.googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
        AppDelegate.googleUser = user
        
        if AppDelegate.signedIntoGoogleInApp == true {
            if let rootDelegate = AppDelegate.appRootDelegate {
                rootDelegate.presentActionSheet()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url)

        return googleDidHandle
    }
}

