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
    
    func previousAction((sender : UITextField!)) {
        println("PreviousAction")
    }
    
    func nextAction((sender : UITextField!)) {
        println("nextAction")
    }
    
    func doneAction((sender : UITextField!)) {
        println("doneAction")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        dropDownTextFie
//        
//        [dropDownTextField setCustomPreviousTarget:self action:@selector(previousAction:)];
//        [dropDownTextField setCustomNextTarget:self action:@selector(nextAction:)];
//        [dropDownTextField setCustomDoneTarget:self action:@selector(doneAction:)];
//        
//        returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
//        [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
//        returnKeyHandler.toolbarManageBehaviour = IQAutoToolbarByPosition;
//        
//        [dropDownTextField setItemList:[NSArray arrayWithObjects:@"Zero Line Of Code",
//        @"No More UIScrollView",
//        @"No More Subclasses",
//        @"No More Manual Work",
//        @"No More #imports",
//        @"Device Orientation support",
//        @"UITextField Category for Keyboard",
//        @"Enable/Desable Keyboard Manager",
//        @"Customize InputView support",
//        @"IQTextView for placeholder support",
//        @"Automanage keyboard toolbar",
//        @"Can set keyboard and textFiled distance",
//        @"Can resign on touching outside",
//        @"Auto adjust textView's height ",
//        @"Adopt tintColor from textField",
//        @"Customize keyboardAppearance",
//        @"play sound on next/prev/done",nil]];
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self);
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
        
        if navigationController != nil {
            
            var controller: UIViewController = storyboard?.instantiateViewControllerWithIdentifier("TextFieldViewController") as! UIViewController
            var navController : UINavigationController = UINavigationController(rootViewController: controller)
            navController.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
            navController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor;
            navController.navigationBar.titleTextAttributes = self.navigationController?.navigationBar.titleTextAttributes;
//            navController.modalTransitionStyle = Int(arc4random()%4)

            // TransitionStylePartialCurl can only be presented by FullScreen style.
//            if (navController.modalTransitionStyle == UIModalTransitionStyle.PartialCurl) {
//                navController.modalPresentationStyle = UIModalPresentationStyle.FullScreen;
//            } else {
//                navController.modalPresentationStyle = UIModalPresentationStyle.PageSheet;
//            }

            presentViewController(controller, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
 
    override func shouldAutorotate() -> Bool {
        return true
    }
}
