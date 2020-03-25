//
//  ContainerViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-03-18.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import PromiseKit

public class ContainerViewController: UIViewController {
    @IBOutlet weak var tabbarContainerView: UIView!
    @IBOutlet weak var hamburgerMenuView: UIView!
    
    let blackTransparentViewTag = 02271994
    var openFlag: Bool = false
    var initialPos: CGPoint?
    var touchPos: CGPoint?
    var alert: UIAlertController?
    
    // ViewController variables
    lazy var frontVC: UIViewController? = {
        let front = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
        return front
    }()
    
    lazy var rearVC: UIViewController? = {
        let rear = self.storyboard?.instantiateViewController(withIdentifier: "Menu")
        return rear
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDelegate.appRootDelegate = self
        displayTabbar()
        addShadowToView()
        setUpNotifications()
        //setUpGestures()
    }
    
    func setUpNotifications() {
        let notificationOpenOrCloseSideMenu = Notification.Name("notificationOpenOrCloseSideMenu")
        NotificationCenter.default.addObserver(self, selector: #selector(openOrCloseSideMenu), name: notificationOpenOrCloseSideMenu, object: nil)
        
        let notificationCloseSideMenu = Notification.Name("notificationCloseSideMenu")
        NotificationCenter.default.addObserver(self, selector: #selector(closeSideMenu), name: notificationCloseSideMenu, object: nil)
        
        let notificationCloseSideMenuWithoutAnimation = Notification.Name("notificationCloseSideMenuWithoutAnimation")
        NotificationCenter.default.addObserver(self, selector: #selector(closeWithoutAnimation), name: notificationCloseSideMenuWithoutAnimation, object: nil)
    }
    
    // To display Tabbar in TabbarContainerView
    func displayTabbar() {
        if let vc = frontVC {
            self.addChild(vc)
            vc.didMove(toParent: self)
            vc.view.frame = self.tabbarContainerView.bounds
            self.tabbarContainerView.addSubview(vc.view)
        }
    }
    
    // To display Menu in Side Menu View
    func displaySideMenu() {
        if !self.children.contains(rearVC!){
            if let vc = rearVC {
                self.addChild(vc)
                vc.didMove(toParent: self)
                vc.view.frame = self.hamburgerMenuView.bounds
                self.hamburgerMenuView.addSubview(vc.view)
            }
        }
    }
    
    
    //MARK: - Shadow View
    func addBlackTransparentView() -> UIView {
        //Black Shadow on MainView(i.e on TabBarController) when side menu is opened.
        let blackView = self.tabbarContainerView.viewWithTag(blackTransparentViewTag)
        if blackView != nil{
            return blackView!
        }else{
            let sView = UIView(frame: self.tabbarContainerView.bounds)
            sView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            sView.tag = blackTransparentViewTag
            sView.alpha = 0
            sView.backgroundColor = UIColor.black
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(closeSideMenu))
            sView.addGestureRecognizer(recognizer)
            return sView
        }
    }
    
    func addShadowToView() {
        //Gives Illusion that main view is above the side menu
        self.tabbarContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        self.tabbarContainerView.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.tabbarContainerView.layer.shadowRadius = 1
        self.tabbarContainerView.layer.shadowOpacity = 1
        self.tabbarContainerView.layer.borderColor = UIColor.lightGray.cgColor
        self.tabbarContainerView.layer.borderWidth = 0.2
    }
    
    //MARK: - Selector Methods
     @objc func openOrCloseSideMenu() {
        self.displaySideMenu()
         //Opens or Closes Side Menu On Click of Button
         if openFlag {
             //This closes Rear View
             let blackTransparentView = self.view.viewWithTag(self.blackTransparentViewTag)
             UIView.animate(withDuration: 0.3, animations: {
                 self.tabbarContainerView.frame = CGRect(x: 0, y: 0, width: self.tabbarContainerView.frame.size.width, height: self.tabbarContainerView.frame.size.height)
                 blackTransparentView?.alpha = 0

             }) { (_) in
                 blackTransparentView?.removeFromSuperview()
                 self.openFlag = false
             }
         } else {
             //This opens Rear View
             UIView.animate(withDuration: 0.0, animations: {
                 self.displaySideMenu()
                 let blackTransparentView = self.addBlackTransparentView()

                 self.tabbarContainerView.addSubview(blackTransparentView)

             }) { (_) in
                 UIView.animate(withDuration: 0.3, animations: {

                 self.addBlackTransparentView().alpha = self.view.bounds.width * 0.8/(self.view.bounds.width * 1.8)
                 self.tabbarContainerView.frame = CGRect(x: self.tabbarContainerView.bounds.size.width * 0.8, y: 0, width: self.tabbarContainerView.frame.size.width, height: self.tabbarContainerView.frame.size.height)
                     }) { (_) in
                        self.openFlag = true
                     }
             }

         }
    
     }
     
     @objc func closeSideMenu(){
         //To close Side Menu
         let blackTransparentView = self.view.viewWithTag(self.blackTransparentViewTag)
             UIView.animate(withDuration: 0.3, animations: {
                 self.tabbarContainerView.frame = CGRect(x: 0, y: 0, width: self.tabbarContainerView.frame.size.width, height: self.tabbarContainerView.frame.size.height)
                 blackTransparentView?.alpha = 0.0
                 
             }) { (_) in
                 blackTransparentView?.removeFromSuperview()
                 self.openFlag = false
             }
     
     }
     
     @objc func closeWithoutAnimation(){
         //To close Side Menu without animation
         let blackTransparentView = self.view.viewWithTag(self.blackTransparentViewTag)
         blackTransparentView?.alpha = 0
         blackTransparentView?.removeFromSuperview()
        self.tabbarContainerView.frame = CGRect(x: 0, y: 0, width: self.tabbarContainerView.frame.size.width, height: self.tabbarContainerView.frame.size.height)
        self.openFlag = false
     }
    
    public func presentActionSheet() {
        var progressController = UIAlertController()
        var progressBar = UIProgressView()
        
        // Creates an action sheet that will appear at the bottom of the screen
        if !UserDefaults.standard.bool(forKey: "googleSignIn") {
            AppDelegate.signedIntoGoogleInApp = true
            let exportActionSheet = UIAlertController(title: "Export Scribe Data\n\n\n", message: nil, preferredStyle: .actionSheet)

            let view = GIDSignInButton(frame: CGRect(x: 8.0, y: 32.0, width: exportActionSheet.view.bounds.size.width - 8.0 * 4.5, height: 50))
            view.accessibilityIdentifier = "GoogleSignIn"
            exportActionSheet.view.addSubview(view)
            GIDSignIn.sharedInstance()?.presentingViewController = exportActionSheet

            exportActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert = exportActionSheet
            present(exportActionSheet, animated: true, completion: nil)
        } else {
            let exportActionSheet = UIAlertController(title: "Export Scribe Data", message: nil, preferredStyle: .actionSheet)
            
            let exportGoogleDriveButton = UIAlertAction(title: "Google Drive", style: .default) { alert -> Void in
                // Present a pop up with a progress indicator
                progressController = UIAlertController(title: "", message: "0 %", preferredStyle: .alert)
                progressController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

                //  Show it to your users
                self.present(progressController, animated: true, completion: {
                    //  Add your progressbar after alert is shown (and measured)
                    let margin: CGFloat = 8.0
                    let rect = CGRect(x: margin, y: 50.0, width: progressController.view.frame.width - margin * 2.0 , height: 2.0)
                    progressBar = UIProgressView(frame: rect)
                    progressController.view.addSubview(progressBar)
                })
                
                firstly {
                    Utility.getExportString()
                }.done { results in
                    Utility.getGoogleDriveFolderID(name: "Scribe Folder", service: AppDelegate.googleDriveService, user: AppDelegate.googleUser!) {
                        if let folderId = $0 {
                            let url = Utility.getDocumentsDirectory().appendingPathComponent("export.txt")

                            do {
                                try results.write(to: url, atomically: true, encoding: .utf8)
                                let input = try String(contentsOf: url)
                                print(input)
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                            Utility.uploadGoogleDriveFile(name: "Scribe Export \(Utility.printTimestamp())", folderID: folderId, fileURL: url, mimeType: "text/plain", service: AppDelegate.googleDriveService, controller: progressController, progressBar: progressBar)
                        } else {
                            Utility.createGoogleDriveFolder(name: "Scribe Folder", service: AppDelegate.googleDriveService) {_ in
                                print("Success")
                            }
                        }
                    }
                }.catch { error in
                    print(error)
                }
            }
            
            if let alert = alert {
                alert.addAction(exportGoogleDriveButton)
                alert.title = "Export Scribe Data"
                for view in alert.view.subviews where view.accessibilityIdentifier == "GoogleSignIn" {
                    view.removeFromSuperview()
                }
            } else {
                exportActionSheet.addAction(exportGoogleDriveButton)
                exportActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(exportActionSheet, animated: true, completion: nil)
            }
        }
    }
}

class HamburgerMenu{
    //Class To Implement Easy Functions To Open Or Close RearView
    //Make object of this class and call functions
    func triggerSideMenu(){
        let notificationOpenOrCloseSideMenu = Notification.Name("notificationOpenOrCloseSideMenu")
        NotificationCenter.default.post(name: notificationOpenOrCloseSideMenu, object: nil)
    }
    
    func closeSideMenu(){
        let notificationCloseSideMenu = Notification.Name("notificationCloseSideMenu")
        NotificationCenter.default.post(name: notificationCloseSideMenu, object: nil)
    }
    
    func closeSideMenuWithoutAnimation(){
        let notificationCloseSideMenuWithoutAnimation = Notification.Name("notificationCloseSideMenuWithoutAnimation")
        NotificationCenter.default.post(name: notificationCloseSideMenuWithoutAnimation, object: nil)
    }
}

