//
//  HTMLUtility.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-08.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import RealmSwift

public class Utility {

    public func getPassageView(passage: Passage, index: Int) -> UIStackView {
        
        let textView = UITextView()
        let attributedPassage = NSMutableAttributedString(string: "\"\(passage.content)\"", attributes: [NSAttributedString.Key.font: UIFont(name: "TimesNewRomanPSMT", size: 12)!])
        textView.attributedText = attributedPassage
        
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.addTarget(self, action: #selector(addNote), for: .touchUpInside)
        button.accessibilityIdentifier = String(index)
        
        var stack = [UIView]()
        stack.append(textView)
        stack.append(button)
        
        let stackView = UIStackView(arrangedSubviews: stack)
        stackView.axis = NSLayoutConstraint.Axis.horizontal

        return stackView
    }
    
    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    @objc func addNote(sender: UIButton!) {
      print("Button tapped??")
    }
}

// Used to resize the text image to within a max dimension while retaining aspect ratio
extension UIImage {
    
    func scaledImage(_ maxDimension: CGFloat) -> UIImage? {
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    
        if size.width > size.height {
            scaledSize.height = size.height / size.width * scaledSize.width
        } else {
            scaledSize.width = size.width / size.height * scaledSize.height
        }
    
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return scaledImage
    }
}
