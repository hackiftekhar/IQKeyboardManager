//
//  TextFieldViewController.swift
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
import IQKeyboardListener
import IQDropDownTextFieldSwift
import IQTextView
import IQKeyboardManagerCore

class TextFieldViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet var textField3: UITextField!
    @IBOutlet var textView1: IQTextView!
    @IBOutlet var textView2: UITextView!
    @IBOutlet var textView3: UITextView!

    let keyboardListener = IQKeyboardListener()

    @IBOutlet var dropDownTextField: IQDropDownTextField!

    @objc func previousAction(_ sender: UITextField) {
        print("PreviousAction")
    }

    @objc func nextAction(_ sender: UITextField) {
        print("nextAction")
    }

    @objc func doneAction(_ sender: UITextField) {
        print("doneAction")
    }

    deinit {
        textView1 = nil
        textField3 = nil
        dropDownTextField = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView1.delegate = self
        textView2.iq.enableMode = .disabled

#if swift(>=5.7)
        if #available(iOS 16.0, *) {
            textView3.isFindInteractionEnabled = true
        }
#endif

        // textView1.attributedPlaceholder = NSAttributedString(string: "Attributed string from code is supported too",
        //                                                      attributes: [.foregroundColor: UIColor.red])

        textField3.iq.toolbar.previousBarButton.setTarget(self, action: #selector(self.previousAction(_:)))
        textField3.iq.toolbar.nextBarButton.setTarget(self, action: #selector(self.nextAction(_:)))
        textField3.iq.toolbar.doneBarButton.setTarget(self, action: #selector(self.doneAction(_:)))
        dropDownTextField.iq.distanceFromKeyboard = 150

        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearAction))
        textField3.iq.toolbar.additionalTrailingItems = [clearButton]

        var itemLists = [String]()
        itemLists.append("Zero Line Of Code")
        itemLists.append("No More UIScrollView")
        itemLists.append("No More Subclasses")
        itemLists.append("No More Manual Work")
        itemLists.append("No More #imports")
        itemLists.append("Device Orientation support")
        itemLists.append("UITextField Category for Keyboard")
        itemLists.append("Enable/Desable Keyboard Manager")
        itemLists.append("Customize InputView support")
        itemLists.append("IQTextView for placeholder support")
        itemLists.append("Automanage keyboard toolbar")
        itemLists.append("Can set keyboard and textFiled distance")
        itemLists.append("Can resign on touching outside")
        itemLists.append("Auto adjust textView's height")
        itemLists.append("Adopt tintColor from textField")
        itemLists.append("Customize keyboardAppearance")
        itemLists.append("Play sound on next/prev/done")

        dropDownTextField.itemList = itemLists
    }

    @objc private func clearAction() {
        textField3.text = ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardListener.registerSizeChange(identifier: "TextFieldViewController") { _, _ in
//            print(size)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardListener.unregisterSizeChange(identifier: "TextFieldViewController")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {

        print("textViewDidBeginEditing")
    }
}
