//
//  NavigationBarViewController.swift
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

class NavigationBarViewController: BaseViewController, UITextFieldDelegate {

    private let returnHandler: IQKeyboardReturnKeyHandler = .init()
    @IBOutlet var textField2: UITextField!
    @IBOutlet var textField3: UITextField!
    @IBOutlet var scrollView: UIScrollView!

    deinit {
        textField2 = nil
        textField3 = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textField3.iq.placeholder = "This is the customised placeholder title for displaying as toolbar title"

        returnHandler.addResponderSubviews(of: self.view, recursive: true)
        returnHandler.lastTextInputViewReturnKeyType = UIReturnKeyType.done
    }

    @IBAction func textFieldClicked(_ sender: UITextField!) {

    }

    @IBAction func enableScrollAction(_ sender: UISwitch!) {
        scrollView.isScrollEnabled = sender.isOn
    }

    @IBAction func shouldHideTitle(_ sender: UISwitch!) {
        textField2.iq.hidePlaceholder = !textField2.iq.hidePlaceholder
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
