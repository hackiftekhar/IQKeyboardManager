//
//  SwitchTableViewCell.swift
//  Demo
//
//  Created by Iftekhar on 26/08/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet var labelTitle : UILabel!
    @IBOutlet var labelSubtitle : UILabel!
    @IBOutlet var switchEnable : UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
