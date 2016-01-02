//
//  BottomBlankSpaceViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit

class BottomBlankSpaceViewController : UIViewController {
    
    @IBOutlet private var switchPreventShowingBottomBlankSpace : UISwitch!

    override func viewWillAppear(animated : Bool) {
        super.viewWillAppear(animated)
        
        switchPreventShowingBottomBlankSpace.on = IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace
    }
    
    @IBAction func preventSwitchAction (sender: UISwitch!) {
        IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
}
