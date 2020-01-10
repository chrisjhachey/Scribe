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

        view.backgroundColor = .white
        
        let textView = UITextView(frame: CGRect(x: 10, y: 10, width: 250, height: 750))
        textView.center = view.center
        textView.textAlignment = NSTextAlignment.justified
        textView.backgroundColor = .white
        textView.attributedText = HTMLUtility.getNSAttributedString(text: text)
        view.addSubview(textView)
    }
    
    public init(text: Text) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
