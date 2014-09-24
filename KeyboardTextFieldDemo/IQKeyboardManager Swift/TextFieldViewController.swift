//
//  TextFieldViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation
import UIKIt

class TextFieldViewController: UIViewController {
    
    @IBOutlet private var buttonPop : UIButton!;
    @IBOutlet private var buttonPush : UIButton!;
    @IBOutlet private var buttonPresent : UIButton!;

    @IBAction func enableKeyboardManger (barButton : UIBarButtonItem!) {
        IQKeyboardManager.sharedManager.enable = true
    }
    
    @IBAction func disableKeyboardManager (barButton : UIBarButtonItem!) {
        IQKeyboardManager.sharedManager.enable = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController == nil {
            buttonPop.hidden = true;
            buttonPush.hidden = true;
            buttonPresent.setTitle("Dismiss", forState: UIControlState.Normal)
        }
    }
    
    override func viewWillAppear(animated : Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.sharedManager.shouldToolbarUsesTextFieldTintColor = true
    }
    
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.sharedManager.shouldToolbarUsesTextFieldTintColor = false

    }
    
    @IBAction func popClicked (sender : AnyObject!) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func presentClicked (sender: AnyObject!) {
        
        if (self.navigationController != nil) {
            
            var controller: UIViewController? = self.storyboard?.instantiateViewControllerWithIdentifier(NSStringFromClass(TextFieldViewController)) as? UIViewController
            
            self.presentViewController(controller!, animated: true, completion: nil)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

