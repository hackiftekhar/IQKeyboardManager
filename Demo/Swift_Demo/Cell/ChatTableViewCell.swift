//
//  ChatTableViewCell.swift
//  Demo
//
//  Created by IEMacBook01 on 23/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//


class ChatLabel: UILabel {
    
    override func intrinsicContentSize() -> CGSize {

        var sizeThatFits = super.intrinsicContentSize()
        sizeThatFits.width += 10
        sizeThatFits.height += 10

        return sizeThatFits
    }
}


class ChatTableViewCell: UITableViewCell {

    @IBOutlet var chatLabel : ChatLabel!
}
