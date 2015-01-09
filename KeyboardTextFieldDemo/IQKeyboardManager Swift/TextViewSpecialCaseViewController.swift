//
//  TextViewSpecialCaseViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation
import UIKIt

class TextViewSpecialCaseViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet private var buttonPop : UIButton!;
    @IBOutlet private var buttonPush : UIButton!;
    @IBOutlet private var buttonPresent : UIButton!;
    @IBOutlet private var barButtonAdjust : UIBarButtonItem!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if IQKeyboardManager.sharedManager().canAdjustTextView {
            barButtonAdjust.title = "Disable Adjust"
        } else {
            barButtonAdjust.title = "Enable Adjust"
        }
        
        if navigationController == nil {
            buttonPop.hidden = true
            buttonPush.hidden = true
            buttonPresent.setTitle("Dismiss", forState: UIControlState.Normal)
        }
    }
    
    
    override func viewWillAppear (animated : Bool) {
        
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().shouldToolbarUsesTextFieldTintColor = true
    }
    
    override func viewWillDisappear (animated : Bool) {
        
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().shouldToolbarUsesTextFieldTintColor = true
    }
    
    @IBAction func canAdjustTextView (barButton : UIBarButtonItem!) {
        
        if barButton.title == "Disable Adjust" {
            IQKeyboardManager.sharedManager().canAdjustTextView = false
            barButton.title = "Enable Adjust"
        } else {
            IQKeyboardManager.sharedManager().canAdjustTextView = true
            barButton.title = "Disable Adjust"
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func popClicked (barButton : UIButton!) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func presentClicked (barButton : UIButton!) {
        
        if (navigationController) != nil {
            var controller : TextViewSpecialCaseViewController = TextViewSpecialCaseViewController()
            presentViewController(controller, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

