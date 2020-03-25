//
//  PassageView.swift
//  Scribe
//
//  Created by Christopher Hachey on 2020-03-17.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

import Foundation
import UIKit

class PassageView: UITableViewCell {

    init(content: String) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "PassageCell")
        
        let contentLabel = UILabel()
        contentLabel.text = content
        
        var stack = [UIView]()
        stack.append(contentLabel)
        
        let stackview = UIStackView(arrangedSubviews: stack)
        stackview.frame = CGRect(x: 50, y: 0, width: 300, height: 50)
        stackview.axis = NSLayoutConstraint.Axis.vertical

        addSubview(stackview)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}
