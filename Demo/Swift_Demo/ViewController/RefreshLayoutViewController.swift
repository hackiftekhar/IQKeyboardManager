//
//  RefreshLayoutViewController.swift
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

class RefreshLayoutViewController: BaseViewController {

    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!

    @IBAction func stepperChanged (_ sender: UIStepper) {

        let finalCurve = UIView.AnimationOptions.beginFromCurrentState.union(.init(rawValue: 7))

        let animationDuration: TimeInterval = 0.3

        UIView.animate(withDuration: animationDuration, delay: 0, options: finalCurve, animations: { () -> Void in

            self.textViewHeightConstraint.constant = CGFloat(sender.value)

            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @IBAction func reloadLayoutAction (_ sender: UIButton) {
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
    }
}
