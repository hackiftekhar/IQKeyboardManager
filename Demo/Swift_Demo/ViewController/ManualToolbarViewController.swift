//
//  ManualToolbarViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ManualToolbarViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var textField1: UITextField!
    @IBOutlet var textField2: UITextField!
    @IBOutlet var textView3: UITextView!
    @IBOutlet var textField4: UITextField!
    @IBOutlet var textField5: UITextField!

    deinit {
        textField1 = nil
        textField2 = nil
        textView3 = nil
        textField4 = nil
        textField5 = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textField1.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(self.previousAction(_:)), nextAction: #selector(self.nextAction(_:)), doneAction: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)
        textField1.keyboardToolbar.previousBarButton.isEnabled = false
        textField1.keyboardToolbar.nextBarButton.isEnabled = true

        textField2.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(self.previousAction(_:)), nextAction: #selector(self.nextAction(_:)), doneAction: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)
        textField2.keyboardToolbar.previousBarButton.isEnabled = true
        textField2.keyboardToolbar.nextBarButton.isEnabled = false

        textView3.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(self.previousAction(_:)), nextAction: #selector(self.nextAction(_:)), doneAction: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)

        textField4.keyboardToolbar.titleBarButton.setTarget(self, action: #selector(self.titleAction(_:)))
        textField4.toolbarPlaceholder = "Saved Passwords"
        textField4.addDoneOnKeyboardWithTarget(self, action: #selector(self.doneAction(_:)), shouldShowPlaceholder: true)

        textField5.inputAccessoryView = UIView()
    }

    @objc func previousAction(_ sender: UITextField!) {

        if textField2.isFirstResponder {
            textView3.becomeFirstResponder()
        } else if textView3.isFirstResponder {
            textField1.becomeFirstResponder()
        }
    }

    @objc func nextAction(_ sender: UITextField!) {

        if textField1.isFirstResponder {
            textView3.becomeFirstResponder()
        } else if textView3.isFirstResponder {
            textField2.becomeFirstResponder()
        }
    }

    @objc func doneAction(_ sender: UITextField!) {
        self.view.endEditing(true)
    }

    @objc func titleAction(_ sender: UIButton) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alertController.addAction(UIAlertAction(title: "test@example.com", style: .default, handler: { (_: UIAlertAction) in
            self.textField4.text = "test"
        }))

        alertController.addAction(UIAlertAction(title: "demo@example.com", style: .default, handler: { (_: UIAlertAction) in
            self.textField4.text = "demo"
        }))

        alertController.popoverPresentationController?.sourceView = sender
        self.present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let identifier = segue.identifier {

            if identifier == "SettingsNavigationController" {

                let controller = segue.destination

                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem

                let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
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
