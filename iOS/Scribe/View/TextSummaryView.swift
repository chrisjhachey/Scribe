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
        
        let image = UIImage(named: "icons8-open-book-96")
        let imageView = UIImageView(image: image)
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
        stackview.frame = CGRect(x: 50, y: 0, width: 300, height: 50)
        stackview.axis = NSLayoutConstraint.Axis.vertical

        addSubview(stackview)
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}
