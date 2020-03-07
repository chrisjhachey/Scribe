//
//  AddNoteViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-11.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import RealmSwift

public class AddNoteViewController: FormViewController {
    let passage: Passage
    let realm = try! Realm()
    
    public override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.createNote))
        
        form +++ Section("Note")
            <<< TextAreaRow(){
                $0.tag = "noteTextArea"
                $0.placeholder = "Add Note"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 96)
            }
        
        super.viewDidLoad()
    }
    
    @objc func createNote() {
        if let noteContent = form.rowBy(tag: "noteTextArea")?.baseValue as? String {
            let note = Note()
            note.content = noteContent
            
//            do {
//                try realm.write {
//                    passage.notes.append(note)
//                }
//            } catch {
//                print("Error: \(error)")
//            }
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    public init(passage: Passage) {
        self.passage = passage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
