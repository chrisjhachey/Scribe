//
//  AppDelegate.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-01.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let defaults = UserDefaults.standard
        let testDataLoaded = defaults.bool(forKey: "testDataLoaded")
        
        // Gives the location of the project's Realm file.
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Gives us the directory for the userDefaults plist
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        
//        do {
//            let realm = try Realm()
//            try! realm.write {
//                realm.deleteAll()
//            }
//        } catch {
//            print("error: \(error)")
//        }
        
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

}

