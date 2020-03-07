//
//  TestViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-15.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import PromiseKit

public class PassageViewController: UIViewController {
    var text: Text!
    var passages = [Passage]()
    
    @IBOutlet weak var textName: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    func update() {
        firstly { () -> Promise<[Passage]> in
            ScribeAPI.shared.get(resourcePath: "\(text.ID)/passage")
        }.done { results in
            self.passages = results
            
            let util = Utility()
            var stack = [UIView]()
            
            let attributedHeader = NSMutableAttributedString(string: "\(self.text.Name)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)])
            self.textName.attributedText = attributedHeader

            for passage in self.passages {
                stack.append(util.getPassageView(passage: passage))
            }

            let stackView = UIStackView(arrangedSubviews: stack)
            stackView.frame = CGRect(x: 50, y: 175, width: 300, height: 350)
            stackView.distribution = .fillEqually
            stackView.axis = NSLayoutConstraint.Axis.vertical
            stackView.spacing = 8
            
            self.view.addSubview(stackView)
            self.view.backgroundColor = .white
        }.catch { error in
            print(error)
        }
    }
    
    @objc func addNote(sender: UIButton!) {
        print(sender.accessibilityIdentifier!)
    
        guard let navigation = self.navigationController else {
            fatalError("UINavigationController returned null")
        }
    
        // TODO this accesibility identifier for the button needs to correspond to the Passage.ID associated for the particular passageView
        navigation.pushViewController(AddNoteViewController(passage: passages[Int(sender.accessibilityIdentifier!)!]), animated: true)
    }
}
