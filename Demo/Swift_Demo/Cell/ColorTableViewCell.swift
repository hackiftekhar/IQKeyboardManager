//
//  ColorTableViewCell.swift
//  Demo
//
//  Created by IEMacBook01 on 23/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

class ColorTableViewCell: UITableViewCell {

    @IBOutlet var labelTitle : UILabel!
    @IBOutlet var labelSubtitle : UILabel!
    @IBOutlet var colorPickerTextField : ColorPickerTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
