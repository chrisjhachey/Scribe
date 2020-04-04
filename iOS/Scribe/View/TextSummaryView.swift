//
//  TextSummaryView.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-01-09.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import UIKit

class TextSummaryView: UITableViewCell {

    init(name: String, author: String) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TextCell")
        
        if !(self.traitCollection.horizontalSizeClass == .regular) {
            let image = UIImage(named: "script")
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 10, y:0, width: 38, height: 38)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.tintColor = UIColor.red
            
            let nameLabel = UILabel()
            nameLabel.text = name
            nameLabel.font = UIFont(name: "ArialRoundedMTBold", size: 18)
            
            let authorLabel = UILabel()
            authorLabel.text = author
            authorLabel.font = UIFont(name: "Cochin-Italic", size: 16)
            
            var stack = [UIView]()
            stack.append(nameLabel)
            stack.append(authorLabel)
            
            let stackview = UIStackView(arrangedSubviews: stack)
            stackview.frame = CGRect(x: 65, y: 0, width: 300, height: 50)
            stackview.axis = NSLayoutConstraint.Axis.vertical

            addSubview(stackview)
            addSubview(imageView)
        } else {
            let image = UIImage(named: "script2")
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 30, y:0, width: 100, height: 100)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.tintColor = UIColor.red
            
            let nameLabel = UILabel()
            nameLabel.text = name
            nameLabel.font = UIFont(name: "ArialRoundedMTBold", size: 26)
            
            let authorLabel = UILabel()
            authorLabel.text = author
            authorLabel.font = UIFont(name: "Cochin-Italic", size: 24)
            
            var stack = [UIView]()
            stack.append(nameLabel)
            stack.append(authorLabel)
            
            let stackview = UIStackView(arrangedSubviews: stack)
            stackview.frame = CGRect(x: 150, y: 18, width: 600, height: 75)
            stackview.axis = NSLayoutConstraint.Axis.vertical

            addSubview(stackview)
            addSubview(imageView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}
