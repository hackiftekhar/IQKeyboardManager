//
//  ManualToolbarViewController.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import IQKeyboardManagerSwift

class ManualToolbarViewController: BaseViewController {

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

        textField1.iq.addPreviousNextDone(target: self,
                                          previousAction: #selector(self.previousAction(_:)),
                                          nextAction: #selector(self.nextAction(_:)),
                                          doneAction: #selector(self.doneAction(_:)),
                                          showPlaceholder: true)
        textField1.iq.toolbar.previousBarButton.isEnabled = false
        textField1.iq.toolbar.nextBarButton.isEnabled = true

        textField2.iq.addPreviousNextDone(target: self,
                                          previousAction: #selector(self.previousAction(_:)),
                                          nextAction: #selector(self.nextAction(_:)),
                                          doneAction: #selector(self.doneAction(_:)),
                                          showPlaceholder: true)
        textField2.iq.toolbar.previousBarButton.isEnabled = true
        textField2.iq.toolbar.nextBarButton.isEnabled = false

        textView3.iq.addPreviousNextDone(target: self,
                                         previousAction: #selector(self.previousAction(_:)),
                                         nextAction: #selector(self.nextAction(_:)),
                                         doneAction: #selector(self.doneAction(_:)),
                                         showPlaceholder: true)

        textField4.iq.toolbar.titleBarButton.setTarget(self, action: #selector(self.titleAction(_:)))
        textField4.iq.placeholder = "Saved Passwords"
        textField4.iq.addDone(target: self, action: #selector(self.doneAction(_:)), showPlaceholder: true)

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

        alertController.addAction(UIAlertAction(title: "test@example.com",
                                                style: .default,
                                                handler: { (_: UIAlertAction) in
            self.textField4.text = "test"
        }))

        alertController.addAction(UIAlertAction(title: "demo@example.com",
                                                style: .default,
                                                handler: { (_: UIAlertAction) in
            self.textField4.text = "demo"
        }))

        alertController.popoverPresentationController?.sourceView = sender
        self.present(alertController, animated: true, completion: nil)
    }
}
