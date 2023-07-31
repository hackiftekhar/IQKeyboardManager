//
//  IQKeyboardManager+OrientationNotification.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-20 Iftekhar Qurashi.
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

// import Foundation - UIKit contains Foundation
import UIKit

// MARK: UIStatusBar Notification methods
@available(iOSApplicationExtension, unavailable)
internal extension IQKeyboardManager {

    /**  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
    @objc func willChangeStatusBarOrientation(_ notification: Notification) {

        let currentStatusBarOrientation: UIInterfaceOrientation
        #if swift(>=5.1)
        if #available(iOS 13, *) {
            currentStatusBarOrientation = keyWindow()?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown
        } else {
            currentStatusBarOrientation = UIApplication.shared.statusBarOrientation
        }
        #else
        currentStatusBarOrientation = UIApplication.shared.statusBarOrientation
        #endif

        guard let statusBarOrientation = notification.userInfo?[UIApplication.statusBarOrientationUserInfoKey] as? Int, currentStatusBarOrientation.rawValue != statusBarOrientation else {
            return
        }

        let startTime = CACurrentMediaTime()
        showLog("📱>>>>> \(#function) started >>>>>", indentation: 1)
        showLog("Notification Object:\(notification.object ?? "NULL")")

        // If textViewContentInsetChanged is saved then restore it.
        if let textView = textFieldView as? UIScrollView, textView.responds(to: #selector(getter: UITextView.isEditable)) {

            if isTextViewContentInsetChanged {
                self.isTextViewContentInsetChanged = false
                if textView.contentInset != self.startingTextViewContentInsets {
                    UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: { () -> Void in

                        self.showLog("Restoring textView.contentInset to: \(self.startingTextViewContentInsets)")

                        // Setting textField to it's initial contentInset
                        textView.contentInset = self.startingTextViewContentInsets
                        textView.scrollIndicatorInsets = self.startingTextViewScrollIndicatorInsets

                    }, completion: { (_) -> Void in })
                }
            }
        }

        restorePosition()

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("📱<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }
}
