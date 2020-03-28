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

public class PassageViewController: UIViewController, UIGestureRecognizerDelegate {
    var text: Text!
    var passages = [Passage]()
    
    @IBOutlet weak var textView: UITextView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        textView.showsVerticalScrollIndicator = false
        
        // Add tap gesture recognizer to Text View
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePassageTap(_:)))
        tap.delegate = self
        textView.addGestureRecognizer(tap)
        
        update()
    }
    
    func update() {
        firstly { () -> Promise<[Passage]> in
            ScribeAPI.shared.get(resourcePath: "\(text.ID)/passage/\(text.UserID)")
        }.done { results in
            self.passages = results
            self.textView.attributedText = Utility.getPassageView(textName: self.text.Name, passages: self.passages)
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
    
    @objc func handlePassageTap(_ sender: UITapGestureRecognizer) {
        let layoutManager = textView.layoutManager
        
        // location of tap in myTextView coordinates and taking the inset into account
        var location = sender.location(in: textView)
        location.x -= textView.textContainerInset.left;
        location.y -= textView.textContainerInset.top;
        
        // character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // if index is valid then get the passage identifier
        if characterIndex < textView.textStorage.length {
            let attributeName = NSAttributedString.Key.passageIdentifier
            let attributeValue = textView.attributedText?.attribute(attributeName, at: characterIndex, effectiveRange: nil)
            if let value = attributeValue as? Int {
                print("You tapped on \(attributeName.rawValue) and the value is: \(value)")
                
                for passage in passages where passage.ID == value {
                    self.present(CreatePassageViewController(text: text, content: passage.Content, passage: passage, parentVC: self), animated: true, completion: nil)
                }
            }
        }
    }
}
