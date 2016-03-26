//
//  CustomViewController.swift
//  Demo
//
//  Created by Iftekhar on 19/09/15.
//  Copyright © 2015 Iftekhar. All rights reserved.
//

class CustomViewController : UIViewController {
    
    private var returnHandler : IQKeyboardReturnKeyHandler!
    @IBOutlet private var switchDisableViewController : UISwitch!
    @IBOutlet private var switchDisableToolbar : UISwitch!
    @IBOutlet private var switchConsiderPreviousNext : UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
            returnHandler = IQKeyboardReturnKeyHandler(controller: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        switchDisableViewController.on = IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.contains(NSStringFromClass(CustomViewController))
        switchDisableToolbar.on = IQKeyboardManager.sharedManager().disabledToolbarClasses.contains(NSStringFromClass(CustomViewController))

        switchConsiderPreviousNext.on = IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses.contains(NSStringFromClass(CustomViewController))
    }
    
    @IBAction func disableInViewControllerAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.insert(NSStringFromClass(CustomViewController))
        }
        else {
            IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.remove(NSStringFromClass(CustomViewController))
        }
    }
    
    @IBAction func disableToolbarAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().disabledToolbarClasses.insert(NSStringFromClass(CustomViewController))
        }
        else {
            IQKeyboardManager.sharedManager().disabledToolbarClasses.remove(NSStringFromClass(CustomViewController))
        }
    }
    
    @IBAction func considerPreviousNextAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses.insert(NSStringFromClass(CustomSubclassView))
        }
        else {
            IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses.remove(NSStringFromClass(CustomSubclassView))
        }
    }
}