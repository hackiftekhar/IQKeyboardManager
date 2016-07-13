//
//  BottomBlankSpaceViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class BottomBlankSpaceViewController : UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet private var switchPreventShowingBottomBlankSpace : UISwitch!

    override func viewWillAppear(animated : Bool) {
        super.viewWillAppear(animated)
        
        switchPreventShowingBottomBlankSpace.on = IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace
    }
    
    @IBAction func preventSwitchAction (sender: UISwitch!) {
        IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = sender.on
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            
            if identifier == "SettingsNavigationController" {
                
                let controller = segue.destinationViewController
                
                controller.modalPresentationStyle = .Popover
                controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
                
                let heightWidth = max(CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds));
                controller.preferredContentSize = CGSizeMake(heightWidth, heightWidth)
                controller.popoverPresentationController?.delegate = self
            }
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        self.view.endEditing(true)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
}
