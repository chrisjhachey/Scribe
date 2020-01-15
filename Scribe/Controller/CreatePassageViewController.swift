//
//  CreatePassageViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-14.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import RealmSwift

public class CreatePassageViewController: FormViewController {
    let text: Text
    let content: String
    let realm = try! Realm()
    
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
                let passage = Passage()
                passage.content = self.form.rowBy(tag: "noteTextArea")?.baseValue as! String
                
                do {
                    try self.realm.write {
                        self.text.passages.append(passage)
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        
        super.viewDidLoad()
    }
    
    public init(text: Text, content: String) {
        self.text = text
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func createPassage() {
        print("Create Passage Button Clicked!")
    }
}
