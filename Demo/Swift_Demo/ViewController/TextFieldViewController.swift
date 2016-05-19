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
    
    @IBOutlet private var textField3 : UITextField!

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
        
        textField3.setCustomTitleTarget(self, action: #selector(self.titleAction(_:)))
        textField3.placeholderText = "Saved Passwords"

        dropDownTextField.setCustomPreviousTarget(self, action: #selector(self.previousAction(_:)))
        dropDownTextField.setCustomNextTarget(self, action: #selector(self.nextAction(_:)))
        dropDownTextField.setCustomDoneTarget(self, action: #selector(self.doneAction(_:)))
        
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
    
    func titleAction(sender : UIButton) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        alertController.addAction(UIAlertAction(title: "test@example.com", style: .Default, handler: { (action : UIAlertAction) in
            self.textField3.text = "test";
        }))
        
        alertController.addAction(UIAlertAction(title: "demo@example.com", style: .Default, handler: { (action : UIAlertAction) in
            self.textField3.text = "demo";
        }))

        self.presentViewController(alertController, animated: true, completion: nil)
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
