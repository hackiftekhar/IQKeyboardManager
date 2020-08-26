//
//  IQKeyboardManager+UITextFieldViewNotification.swift
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

import Foundation

// MARK: UITextField/UITextView Notifications
internal extension IQKeyboardManager {

    /**  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
    @objc func textFieldViewDidBeginEditing(_ notification: Notification) {

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //  Getting object
        textFieldView = notification.object as? UIView

        if overrideKeyboardAppearance == true {
            if let textInput = textFieldView as? UITextInput {
                if textInput.keyboardAppearance != keyboardAppearance {
                    //Setting textField keyboard appearance and reloading inputViews.
                    if let textFieldView = textFieldView as? UITextField {
                        textFieldView.keyboardAppearance = keyboardAppearance
                    } else if  let textFieldView = textFieldView as? UITextView {
                        textFieldView.keyboardAppearance = keyboardAppearance
                    }
                    textFieldView?.reloadInputViews()
                }
            }
        }

        //If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
        if privateIsEnableAutoToolbar() == true {

            //UITextView special case. Keyboard Notification is firing before textView notification so we need to resign it first and then again set it as first responder to add toolbar on it.
            if let textView = textFieldView as? UIScrollView, textView.responds(to: #selector(getter: UITextView.isEditable)),
                textView.inputAccessoryView == nil {

                UIView.animate(withDuration: 0.00001, delay: 0, options: animationCurve, animations: { () -> Void in

                    self.addToolbarIfRequired()

                }, completion: { (_) -> Void in

                    //On textView toolbar didn't appear on first time, so forcing textView to reload it's inputViews.
                    textView.reloadInputViews()
                })
            } else {
                //Adding toolbar
                addToolbarIfRequired()
            }
        } else {
            removeToolbarIfRequired()
        }

        resignFirstResponderGesture.isEnabled = privateShouldResignOnTouchOutside()
        textFieldView?.window?.addGestureRecognizer(resignFirstResponderGesture)    //   (Enhancement ID: #14)

        if privateIsEnabled() == false {
            restorePosition()
            topViewBeginOrigin = IQKeyboardManager.kIQCGPointInvalid
        } else {
            if topViewBeginOrigin.equalTo(IQKeyboardManager.kIQCGPointInvalid) == true {    //  (Bug ID: #5)

                rootViewController = textFieldView?.parentContainerViewController()

                if let controller = rootViewController {

                    if rootViewControllerWhilePopGestureRecognizerActive == controller {
                        topViewBeginOrigin = topViewBeginOriginWhilePopGestureRecognizerActive
                    } else {
                        topViewBeginOrigin = controller.view.frame.origin
                    }

                    rootViewControllerWhilePopGestureRecognizerActive = nil
                    topViewBeginOriginWhilePopGestureRecognizerActive = IQKeyboardManager.kIQCGPointInvalid

                    self.showLog("Saving \(controller) beginning origin: \(self.topViewBeginOrigin)")
                }
            }

            //If textFieldView is inside ignored responder then do nothing. (Bug ID: #37, #74, #76)
            //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).
            if keyboardShowing == true,
                let textFieldView = textFieldView,
                textFieldView.isAlertViewTextField() == false {

                //  keyboard is already showing. adjust position.
                optimizedAdjustPosition()
            }
        }

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }

    /**  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
    @objc func textFieldViewDidEndEditing(_ notification: Notification) {

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //Removing gesture recognizer   (Enhancement ID: #14)
        textFieldView?.window?.removeGestureRecognizer(resignFirstResponderGesture)

        // We check if there's a change in original frame or not.

        if let textView = textFieldView as? UIScrollView, textView.responds(to: #selector(getter: UITextView.isEditable)) {

            if isTextViewContentInsetChanged == true {
                self.isTextViewContentInsetChanged = false

                if textView.contentInset != self.startingTextViewContentInsets {
                    self.showLog("Restoring textView.contentInset to: \(self.startingTextViewContentInsets)")

                    UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: { () -> Void in

                        //Setting textField to it's initial contentInset
                        textView.contentInset = self.startingTextViewContentInsets
                        textView.scrollIndicatorInsets = self.startingTextViewScrollIndicatorInsets

                    }, completion: { (_) -> Void in })
                }
            }
        }

        //Setting object to nil
        textFieldView = nil

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }
}
