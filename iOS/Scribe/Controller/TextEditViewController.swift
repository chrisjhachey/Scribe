//
//  TextEditViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-03-28.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import Eureka
import PromiseKit

public class TextEditViewController: FormViewController {
    var text: Text
    let parentVC: PassageViewController!
    
    public required init(text: Text, parentVC: PassageViewController) {
        self.text = text
        self.parentVC = parentVC
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        
        form
        
        +++ Section("Name")
        <<< TextRow() { row in
                row.tag = "name"
                row.baseValue = text.Name
            }
            
        +++ Section("Author")
        <<< TextRow() { row in
                row.tag = "author"
                row.baseValue = text.Author
            }
        
        +++ Section()
        <<< ButtonRow() { row in
                row.tag = "save"
                row.title = "Save"
        }
        
        .onCellSelection {  cell, row in
            self.text.Name = self.form.rowBy(tag: "name")?.baseValue as! String
            self.text.Author = (self.form.rowBy(tag: "author")?.baseValue as! String)
            
            firstly {
                ScribeAPI.shared.patch(resourcePath: "text", entity: self.text)
            }.done { results in
                print(results)
                self.parentVC.update()
                
                if let vc = self.parentVC.parent {
                    let navStack = vc.children
                    for vc in navStack where vc.restorationIdentifier == "textTableVC" {
                        if let textTable = vc as? TextTableViewController {
                            textTable.update()
                        }
                    }
                }
                
                self.dismiss(animated: true, completion: nil)
            }.catch { error in
                print(error)
            }
        }
        
        super.viewDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
    }
}
