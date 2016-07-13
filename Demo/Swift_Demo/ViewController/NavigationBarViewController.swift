//
//  NavigationBarViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class NavigationBarViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    private var returnKeyHandler : IQKeyboardReturnKeyHandler!
    @IBOutlet private var textField2 : UITextField!
    @IBOutlet private var textField3 : UITextField!
    @IBOutlet private var scrollView : UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        textField3.placeholderText = "This is the customised placeholder title for displaying as toolbar title"

        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
    }

    @IBAction func textFieldClicked(sender : UITextField!) {
        
    }
    
    @IBAction func enableScrollAction(sender : UISwitch!) {
        scrollView.scrollEnabled = sender.on;
    }
    
    @IBAction func shouldHideTitle(sender : UISwitch!) {
        textField2.shouldHidePlaceholderText = !textField2.shouldHidePlaceholderText;
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

