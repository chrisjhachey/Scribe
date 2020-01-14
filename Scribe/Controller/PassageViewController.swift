//
//  PassageViewController.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-07.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import UIKit
import RealmSwift

public class PassageViewController: UIViewController {
    let text: Text
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let util = HTMLUtility()
        var stack = [UIView]()
        
        let attributedHeader = NSMutableAttributedString(string: "\(text.name)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)])
        
        let headerView = UITextView(frame: CGRect(x: 100, y: 20, width: 225, height: 100))
        headerView.attributedText = attributedHeader

        for passage in text.passages {
            stack.append(util.getPassageView(passage: passage, index: text.passages.index(of: passage)!))
        }

        let stackView = UIStackView(arrangedSubviews: stack)
        stackView.frame = CGRect(x: 100, y: 150, width: 225, height: 250)
        stackView.distribution = .fillProportionally
        stackView.axis = NSLayoutConstraint.Axis.vertical

        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(stackView)
    }
    
    public init(text: Text) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addNote(sender: UIButton!) {
        print(sender.accessibilityIdentifier!)
        
        guard let navigation = self.navigationController else {
            fatalError("UINavigationController returned null")
        }

        navigation.pushViewController(AddNoteViewController(passage: text.passages[Int(sender.accessibilityIdentifier!)!]), animated: true)
    }
}
