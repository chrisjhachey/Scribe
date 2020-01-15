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

public class PassageViewController: UIViewController {
    var text: Text!
    
    @IBOutlet weak var textName: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let util = Utility()
        var stack = [UIView]()
        
        let attributedHeader = NSMutableAttributedString(string: "\(text.name)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)])
        textName.attributedText = attributedHeader

        for passage in text.passages {
            stack.append(util.getPassageView(passage: passage, index: text.passages.index(of: passage)!))
        }

        let stackView = UIStackView(arrangedSubviews: stack)
        stackView.frame = CGRect(x: 75, y: 175, width: 300, height: 250)
        stackView.distribution = .fillProportionally
        stackView.axis = NSLayoutConstraint.Axis.vertical
        
        view.backgroundColor = .white
        view.addSubview(stackView)
    }
    
    @objc func addNote(sender: UIButton!) {
        print(sender.accessibilityIdentifier!)
    
        guard let navigation = self.navigationController else {
            fatalError("UINavigationController returned null")
        }
    
        navigation.pushViewController(AddNoteViewController(passage: text.passages[Int(sender.accessibilityIdentifier!)!]), animated: true)
    }
}
