//
//  CustomViewController.swift
//  Demo
//
//  Created by Iftekhar on 19/09/15.
//  Copyright © 2015 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CustomViewController : UIViewController, UIPopoverPresentationControllerDelegate {
    
    private var returnHandler : IQKeyboardReturnKeyHandler!
    @IBOutlet private var settingsView : UIView!

    @IBOutlet private var switchDisableViewController : UISwitch!
    @IBOutlet private var switchEnableViewController : UISwitch!

    @IBOutlet private var switchDisableToolbar : UISwitch!
    @IBOutlet private var switchEnableToolbar : UISwitch!
    
    @IBOutlet private var switchDisableTouchResign : UISwitch!
    @IBOutlet private var switchEnableTouchResign : UISwitch!

    @IBOutlet private var switchAllowPreviousNext : UISwitch!

    @IBOutlet private var settingsTopConstraint : NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsView.layer.shadowColor = UIColor.blackColor().CGColor
        settingsView.layer.shadowOffset = CGSizeZero
        settingsView.layer.shadowRadius = 5.0
        settingsView.layer.shadowOpacity = 0.5

        returnHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnHandler.lastTextFieldReturnKeyType = .Done
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        switchDisableViewController.on = IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.contains({ element in
            return element == CustomViewController.self
        })
        
        switchEnableViewController.on = IQKeyboardManager.sharedManager().enabledDistanceHandlingClasses.contains({ element in
            return element == CustomViewController.self
        })
        
        switchDisableToolbar.on = IQKeyboardManager.sharedManager().disabledToolbarClasses.contains({ element in
            return element == CustomViewController.self
        })
        switchEnableToolbar.on = IQKeyboardManager.sharedManager().enabledToolbarClasses.contains({ element in
            return element == CustomViewController.self
        })
        
        switchDisableTouchResign.on = IQKeyboardManager.sharedManager().disabledTouchResignedClasses.contains({ element in
            return element == CustomViewController.self
        })
        switchEnableTouchResign.on = IQKeyboardManager.sharedManager().enabledTouchResignedClasses.contains({ element in
            return element == CustomViewController.self
        })
                
        switchAllowPreviousNext.on = IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses.contains({ element in
            return element == IQPreviousNextView.self
        });
    }
    
    @IBAction func tapAction(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {

            let animationCurve = UIViewAnimationOptions.init(rawValue: 7)
            let animationDuration : NSTimeInterval = 0.3;
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(animationCurve), animations: { () -> Void in

                if self.settingsTopConstraint.constant != 0 {
                    self.settingsTopConstraint.constant = 0;
                } else {
                    self.settingsTopConstraint.constant = -self.settingsView.frame.size.height+30;
                }
                
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }) { (animated:Bool) -> Void in}
        }
    }

    @IBAction func disableInViewControllerAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.append(CustomViewController)
        }
        else {
            
            if let index = IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.indexOf({ element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.removeAtIndex(index)
            }
        }
    }
    
    @IBAction func enableInViewControllerAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().enabledDistanceHandlingClasses.append(CustomViewController)
        }
        else {
            
            if let index = IQKeyboardManager.sharedManager().enabledDistanceHandlingClasses.indexOf({ element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.sharedManager().enabledDistanceHandlingClasses.removeAtIndex(index)
            }
        }
    }
    
    @IBAction func disableToolbarAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().disabledToolbarClasses.append(CustomViewController)
        }
        else {

            if let index = IQKeyboardManager.sharedManager().disabledToolbarClasses.indexOf({ element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.sharedManager().disabledToolbarClasses.removeAtIndex(index)
            }
        }
    }
    
    @IBAction func enableToolbarAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().enabledToolbarClasses.append(CustomViewController)
        }
        else {
            if let index = IQKeyboardManager.sharedManager().enabledToolbarClasses.indexOf({ element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.sharedManager().enabledToolbarClasses.removeAtIndex(index)
            }
        }
    }
    
    @IBAction func disableTouchOutsideAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().disabledTouchResignedClasses.append(CustomViewController)
        }
        else {
            if let index = IQKeyboardManager.sharedManager().disabledTouchResignedClasses.indexOf({ element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.sharedManager().disabledTouchResignedClasses.removeAtIndex(index)
            }
        }
    }
    
    @IBAction func enableTouchOutsideAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().enabledTouchResignedClasses.append(CustomViewController)
        }
        else {
            
            if let index = IQKeyboardManager.sharedManager().enabledTouchResignedClasses.indexOf({ element in
                return element == CustomViewController.self
            }) {
                IQKeyboardManager.sharedManager().enabledTouchResignedClasses.removeAtIndex(index)
            }
        }
    }
    
    @IBAction func allowedPreviousNextAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses.append(IQPreviousNextView)
        }
        else {
            
            if let index = IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses.indexOf({ element in
                return element == IQPreviousNextView.self
            }) {
                IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses.removeAtIndex(index)
            }
        }
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