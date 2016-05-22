//
//  StepperTableViewCell.swift
//  Demo
//
//  Created by Iftekhar on 26/08/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

class StepperTableViewCell: UITableViewCell {

    @IBOutlet var labelTitle : UILabel!
    @IBOutlet var labelSubtitle : UILabel!
    @IBOutlet var stepper : UIStepper!
    @IBOutlet var labelStepperValue : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
