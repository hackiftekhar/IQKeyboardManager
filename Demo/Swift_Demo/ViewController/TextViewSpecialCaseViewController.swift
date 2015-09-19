//
//  TextViewSpecialCaseViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation
import UIKit

class TextViewSpecialCaseViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet private var buttonPush : UIButton!
    @IBOutlet private var buttonPresent : UIButton!
    @IBOutlet private var barButtonAdjust : UIBarButtonItem!
    
    @IBAction func canAdjustTextView (barButton : UIBarButtonItem!) {
        
        if (IQKeyboardManager.sharedManager().canAdjustTextView == true) {
            IQKeyboardManager.sharedManager().canAdjustTextView = false
        } else {
            IQKeyboardManager.sharedManager().canAdjustTextView = true
        }

        refreshUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.navigationController == nil)
        {
            buttonPush.hidden = true
            buttonPresent.setTitle("Dismiss", forState: UIControlState.Normal)
        }
    }
    
    override func viewWillAppear (animated : Bool) {
        
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    func refreshUI() {
        if (IQKeyboardManager.sharedManager().canAdjustTextView == true) {
            barButtonAdjust.title = "Disable Adjust"
        } else {
            barButtonAdjust.title = "Enable Adjust"
        }
    }

    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func presentClicked (barButton : UIButton!) {
        
        if (navigationController) != nil {
            let controller : TextViewSpecialCaseViewController = TextViewSpecialCaseViewController()
            presentViewController(controller, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

}

