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
    
    @IBOutlet fileprivate var switchPreventShowingBottomBlankSpace : UISwitch!

    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        
        switchPreventShowingBottomBlankSpace.isOn = IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace
    }
    
    @IBAction func preventSwitchAction (_ sender: UISwitch!) {
        IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = sender.isOn
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            
            if identifier == "SettingsNavigationController" {
                
                let controller = segue.destination
                
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
                
                let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height);
                controller.preferredContentSize = CGSize(width: heightWidth, height: heightWidth)
                controller.popoverPresentationController?.delegate = self
            }
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        self.view.endEditing(true)
    }

    override var shouldAutorotate : Bool {
        return true
    }
}
