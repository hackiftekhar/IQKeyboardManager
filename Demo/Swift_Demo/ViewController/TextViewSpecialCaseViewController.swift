//
//  TextViewSpecialCaseViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit

class TextViewSpecialCaseViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet private var buttonPush : UIButton!
    @IBOutlet private var buttonPresent : UIButton!
    
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

