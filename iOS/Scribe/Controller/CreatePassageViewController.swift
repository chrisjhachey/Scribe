//
//  CreatePassageViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-14.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit
import Eureka

public class CreatePassageViewController: FormViewController {
    let text: Text
    let content: String
    let passage: Passage?
    let parentVC: PassageViewController?
    
    public override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.createPassage))
        
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        form +++ Section("Passage")
            <<< TextAreaRow(){
                $0.tag = "noteTextArea"
                $0.baseValue = trimmedContent
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 300)
            }
        
            <<< ButtonRow() {
                $0.title = "Commit"
            }
        
            .onCellSelection {  cell, row in
                if let passage = self.passage {
                    passage.Content = self.form.rowBy(tag: "noteTextArea")?.baseValue as! String
                    
                    firstly {
                        ScribeAPI.shared.patch(resourcePath: "passage", entity: passage)
                    }.done { results in
                        print(results)
                    }.catch { error in
                        print(error)
                    }
                    
                    if let passageVC = self.parentVC {
                        passageVC.update()
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let passage = Passage()
                    passage.Content = self.form.rowBy(tag: "noteTextArea")?.baseValue as! String
                    passage.TextID = self.text.ID
                    
                    guard let userId = Context.shared.userId else {
                        fatalError("No user id found in session!")
                    }
                    
                    passage.UserID = userId
                    
                    firstly {
                        ScribeAPI.shared.post(resourcePath: "passage", entity: passage)
                    }.done { results in
                        print(results)
                    }.catch { error in
                        print(error)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        
        <<< ButtonRow() {
            if let passage = passage {
                $0.title = "Discard"
            } else {
                $0.title = "Cancel"
            }
            
        }
        
        .onCellSelection {  cell, row in
            self.dismiss(animated: true, completion: nil)
        }
        
        super.viewDidLoad()
    }
    
    public init(text: Text, content: String, passage: Passage?, parentVC: PassageViewController?) {
        self.text = text
        self.content = content
        self.passage = passage
        self.parentVC = parentVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func createPassage() {
        print("Create Passage Button Clicked!")
    }
}
