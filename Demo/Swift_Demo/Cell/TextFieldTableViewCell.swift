//
//  TextFieldTableViewCell.swift
//  Demo
//
//  Created by IEMacBook01 on 23/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//


class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet var labelTitle : UILabel!
    @IBOutlet var labelSubtitle : UILabel!
    @IBOutlet var textField : UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
