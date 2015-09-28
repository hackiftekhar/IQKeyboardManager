//
//  ManualToolbarViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit

class ManualToolbarViewController : UIViewController {
    
    @IBOutlet private var textField1 : UITextField!
    @IBOutlet private var textField2 : UITextField!
    @IBOutlet private var textView3 : UITextView!
    @IBOutlet private var textField4 : UITextField!
    @IBOutlet private var textField5 : UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField1.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: Selector("previousAction"), nextAction: Selector("nextAction"), doneAction: Selector("doneAction"))
        textField1.setEnablePrevious(false, isNextEnabled: true)
        
        textField2.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: Selector("previousAction"), nextAction: Selector("nextAction"), doneAction: Selector("doneAction"))

        textView3.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: Selector("previousAction"), nextAction: Selector("nextAction"), doneAction: Selector("doneAction"))

        textField4.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: Selector("previousAction"), nextAction: Selector("nextAction"), doneAction: Selector("doneAction"))
        textField4.setEnablePrevious(false, isNextEnabled: true)

        textField5.inputAccessoryView = UIView()
    }
    
    
    func previousAction(sender : UITextField!) {
        
        if (textField4.isFirstResponder())
        {
            textField2.becomeFirstResponder()
        }
        else if (textField2.isFirstResponder())
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
        else if (textField2.isFirstResponder())
        {
            textField4.becomeFirstResponder()
        }
    }
    
    func doneAction(sender : UITextField!) {
        self.view.endEditing(true)
    }

    
    override func shouldAutorotate() -> Bool {
        return true
    }
}
