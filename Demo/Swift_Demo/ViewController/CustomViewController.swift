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
        switchDisableViewController.on = IQKeyboardManager.sharedManager().disabledInViewControllerClassesString().contains(NSStringFromClass(CustomViewController))
        switchDisableToolbar.on = IQKeyboardManager.sharedManager().disabledInViewControllerClassesString().contains(NSStringFromClass(CustomViewController))

        switchConsiderPreviousNext.on = IQKeyboardManager.sharedManager().consideredToolbarPreviousNextViewClassesString().contains(NSStringFromClass(CustomViewController))
    }
    
    @IBAction func disableInViewControllerAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().disableDistanceHandlingInViewControllerClass(CustomViewController)
        }
        else {
            IQKeyboardManager.sharedManager().removeDisableDistanceHandlingInViewControllerClass(CustomViewController)
        }
    }
    
    @IBAction func disableToolbarAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().disableToolbarInViewControllerClass(CustomViewController)
        }
        else {
            IQKeyboardManager.sharedManager().removeDisableToolbarInViewControllerClass(CustomViewController)
        }
    }
    
    @IBAction func considerPreviousNextAction(sender: UISwitch) {
        self.view.endEditing(true)
        if sender.on {
            IQKeyboardManager.sharedManager().considerToolbarPreviousNextInViewClass(CustomSubclassView)
        }
        else {
            IQKeyboardManager.sharedManager().removeConsiderToolbarPreviousNextInViewClass(CustomSubclassView)
        }
    }
}