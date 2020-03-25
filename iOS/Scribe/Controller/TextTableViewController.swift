//
//  TextTableViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-04.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import UIKit
import RealmSwift
import PromiseKit

public class TextTableViewController: UITableViewController {
    let realm = try! Realm()
    var texts = [Text]()
    var segueText: Text?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "All Texts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addText(sender:)))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        update()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
        let text = texts[indexPath.item]
        let summary = TextSummaryView(name: text.Name, author: text.Author!)
        
        cell.subviews.forEach({ $0.removeFromSuperview() })
        cell.addSubview(summary)
    
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        segueText = texts[indexPath.item]
        self.performSegue(withIdentifier: "goToPassage", sender: self)
    }
    
    public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let unstarAction = UIContextualAction(style: .destructive, title: "Remove") { (_, _, completionHandler) in
            completionHandler(false)
            let deleteAlert = UIAlertController(title: "Remove Text", message: "This will remove the Text permanently", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title: "Yes, Remove", style: .destructive, handler: { (_) in
                let textToDelete = self.texts[indexPath.row]
                
                // TODO sometimes the table view doesn't seem to update on a delete even though the DB removes the text and returns the new list...
                ScribeAPI.shared.delete(resourcePath: "text/\(textToDelete.ID)")
                
                self.update()
            }))

            deleteAlert.addAction(UIAlertAction(title: "Don't Remove", style: .cancel, handler: nil))
            self.present(deleteAlert, animated: true, completion: nil)
        }

        let swipeConfig = UISwipeActionsConfiguration(actions: [unstarAction])
        
        return swipeConfig
    }
    
    public func update() {
        guard let userId = Context.shared.userId else {
            fatalError("No user id found in session!")
        }
        
        firstly { () -> Promise<[Text]> in
            ScribeAPI.shared.get(resourcePath: "text/\(userId)")
        }.done { results in
            self.texts = results
            let vc = self.tabBarController?.viewControllers![0] as! HomeViewController
            vc.update()
            self.tableView.reloadData()
        }.catch { error in
            print(error)
        }
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
            let text = Text()
            text.Name = nameTextField.text!
            text.Author = authorTextField.text!
            text.UserID = Context.shared.userId!
            
            firstly {
                ScribeAPI.shared.post(resourcePath: "text", entity: text)
            }.done { results in
//                self.texts.append(contentsOf: results)
//                self.tableView.reloadData()
                self.update()
            }.catch { error in
                print(error)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "goToPassage" {
           let destinationVC = segue.destination as! PassageViewController
           destinationVC.text = segueText
       }
    }
}
