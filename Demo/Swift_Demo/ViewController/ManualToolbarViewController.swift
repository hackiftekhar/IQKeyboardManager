//
//  ManualToolbarViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ManualToolbarViewController : UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet private var textField1 : UITextField!
    @IBOutlet private var textField2 : UITextField!
    @IBOutlet private var textView3 : UITextView!
    @IBOutlet private var textField4 : UITextField!
    @IBOutlet private var textField5 : UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField1.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(self.previousAction(_:)), nextAction: #selector(self.nextAction(_:)), doneAction: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)
        textField1.setEnablePrevious(false, isNextEnabled: true)
        
        textField2.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(self.previousAction(_:)), nextAction: #selector(self.nextAction(_:)), doneAction: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)
        textField2.setEnablePrevious(true, isNextEnabled: false)

        textView3.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(self.previousAction(_:)), nextAction: #selector(self.nextAction(_:)), doneAction: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)

        textField4.setTitleTarget(self, action: #selector(self.titleAction(_:)))
        textField4.placeholderText = "Saved Passwords"
        textField4.addDoneOnKeyboardWithTarget(self, action: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)

        textField5.inputAccessoryView = UIView()
    }

    
    func previousAction(sender : UITextField!) {
        
        if (textField2.isFirstResponder())
        {
            textView3.becomeFirstResponder()
        }
        else if (textView3.isFirstResponder())
        {
            textField1.becomeFirstResponder()
        }
    }
    
    func nextAction(sender : UITextField!) {
        
        if (textField1.isFirstResponder())
        {
            textView3.becomeFirstResponder()
        }
        else if (textView3.isFirstResponder())
        {
            textField2.becomeFirstResponder()
        }
    }
    
    func doneAction(sender : UITextField!) {
        self.view.endEditing(true)
    }

    func titleAction(sender : UIButton) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "test@example.com", style: .Default, handler: { (action : UIAlertAction) in
            self.textField4.text = "test";
        }))
        
        alertController.addAction(UIAlertAction(title: "demo@example.com", style: .Default, handler: { (action : UIAlertAction) in
            self.textField4.text = "demo";
        }))
        
        alertController.popoverPresentationController?.sourceView = sender
        self.presentViewController(alertController, animated: true, completion: nil)
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
