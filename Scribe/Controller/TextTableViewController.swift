//
//  TextTableViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-04.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import UIKit
import RealmSwift

public class TextTableViewController: UITableViewController {
    let realm = try! Realm()
    var texts: Results<Text>?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        texts = realm.objects(Text.self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        
        navigationItem.title = "All Texts"

        tableView.delegate = self
        tableView.estimatedRowHeight = 600
        //tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = UIRefreshControl()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addText(sender:)))
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts?.count ?? 1
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
        let text = texts?[indexPath.item]
        let summary = TextSummaryView(name: text!.name, author: text!.author!)
        
        cell.addSubview(summary)
    
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navigation = self.navigationController else {
            fatalError("UINavigationController returned null")
        }

        navigation.pushViewController(PassageViewController(text: texts![indexPath.item]), animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 345
    }
    
    public func update() {
        texts = realm.objects(Text.self)
        let vc = self.tabBarController?.viewControllers![0] as! HomeViewController
        vc.textsUpdated()
        self.tableView.reloadData()
    }
    
    @objc public func addText(sender: UIBarButtonItem) {
        var nameTextField = UITextField()
        var authorTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Text", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Name"
            nameTextField = alertTextField
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Author"
            authorTextField = alertTextField
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            let text = Text(name: nameTextField.text!)
            text.author = authorTextField.text!
            
            do {
                try self.realm.write {
                    self.realm.add(text)
                    self.update()
                }
            } catch {
                print("Failed to initialize Realm: \(error)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
