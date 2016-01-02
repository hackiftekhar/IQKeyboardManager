//
//  TextFieldViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation
import UIKit

class TextFieldViewController: UIViewController {
    
    private var returnKeyHandler : IQKeyboardReturnKeyHandler!
    @IBOutlet private var dropDownTextField : IQDropDownTextField!

    @IBOutlet private var buttonPush : UIButton!
    @IBOutlet private var buttonPresent : UIButton!
    @IBOutlet private var barButtonDisable : UIBarButtonItem!

    @IBAction func disableKeyboardManager (barButton : UIBarButtonItem!) {
        
        if (IQKeyboardManager.sharedManager().enable == true) {
            IQKeyboardManager.sharedManager().enable = false
        } else {
            IQKeyboardManager.sharedManager().enable = true
        }

        refreshUI()
    }
    
    func previousAction(sender : UITextField) {
        print("PreviousAction")
    }
    
    func nextAction(sender : UITextField) {
        print("nextAction")
    }
    
    func doneAction(sender : UITextField) {
        print("doneAction")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDownTextField.setCustomPreviousTarget(self, selector: Selector("previousAction:"))
        dropDownTextField.setCustomNextTarget(self, selector: Selector("nextAction:"))
        dropDownTextField.setCustomDoneTarget(self, selector: Selector("doneAction:"))
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        var itemLists = [NSString]()
        itemLists.append("Zero Line Of Code")
        itemLists.append("No More UIScrollView")
        itemLists.append("No More Subclasses")
        itemLists.append("No More Manual Work")
        itemLists.append("No More #imports")
        itemLists.append("Device Orientation support")
        itemLists.append("UITextField Category for Keyboard")
        itemLists.append("Enable/Desable Keyboard Manager")
        itemLists.append("Customize InputView support")
        itemLists.append("IQTextView for placeholder support")
        itemLists.append("Automanage keyboard toolbar")
        itemLists.append("Can set keyboard and textFiled distance")
        itemLists.append("Can resign on touching outside")
        itemLists.append("Auto adjust textView's height")
        itemLists.append("Adopt tintColor from textField")
        itemLists.append("Customize keyboardAppearance")
        itemLists.append("Play sound on next/prev/done")

        dropDownTextField.itemList = itemLists
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
    }
    
    override func viewWillAppear(animated : Bool) {
        super.viewWillAppear(animated)
        
        if (self.presentingViewController != nil)
        {
            buttonPush.hidden = true
            buttonPresent.setTitle("Dismiss", forState:UIControlState.Normal)
        }
        
        refreshUI()
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.sharedManager().shouldToolbarUsesTextFieldTintColor = false

    }
    
    func refreshUI() {
        if (IQKeyboardManager.sharedManager().enable == true) {
            barButtonDisable.title = "Disable"
        } else {
            barButtonDisable.title = "Enable"
        }
    }
    
    @IBAction func presentClicked (sender: AnyObject!) {
        
        if self.presentingViewController == nil {
            
            let controller: UIViewController = (storyboard?.instantiateViewControllerWithIdentifier("TextFieldViewController"))!
            let navController : UINavigationController = UINavigationController(rootViewController: controller)
            navController.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
            navController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
            navController.navigationBar.titleTextAttributes = self.navigationController?.navigationBar.titleTextAttributes
//            navController.modalTransitionStyle = Int(arc4random()%4)

            // TransitionStylePartialCurl can only be presented by FullScreen style.
//            if (navController.modalTransitionStyle == UIModalTransitionStyle.PartialCurl) {
//                navController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
//            } else {
//                navController.modalPresentationStyle = UIModalPresentationStyle.PageSheet
//            }

            presentViewController(navController, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
 
    override func shouldAutorotate() -> Bool {
        return true
    }
}
