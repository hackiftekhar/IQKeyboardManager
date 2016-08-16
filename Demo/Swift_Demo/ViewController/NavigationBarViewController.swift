//
//  NavigationBarViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation
import UIKit

class NavigationBarViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    private var returnKeyHandler : IQKeyboardReturnKeyHandler!
    @IBOutlet private var textField2 : UITextField!
    @IBOutlet private var textField3 : UITextField!
    @IBOutlet private var scrollView : UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        textField3.placeholderText = "This is the customised placeholder title for displaying as toolbar title"

        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }

    @IBAction func textFieldClicked(_ sender : UITextField!) {
        
    }
    
    @IBAction func enableScrollAction(_ sender : UISwitch!) {
        scrollView.isScrollEnabled = sender.isOn;
    }
    
    @IBAction func shouldHideTitle(_ sender : UISwitch!) {
        textField2.shouldHidePlaceholderText = !textField2.shouldHidePlaceholderText;
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            
            if identifier == "SettingsNavigationController" {
                
                let controller = segue.destination
                
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
                
                let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height);
                controller.preferredContentSize = CGSize(width: heightWidth, height: heightWidth)
                controller.popoverPresentationController?.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        self.view.endEditing(true)
    }
    
	override var shouldAutorotate: Bool {
        return true
    }
}

