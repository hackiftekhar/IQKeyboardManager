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

import UIKit

// MARK: UITextField/UITextView Notifications
@available(iOSApplicationExtension, unavailable)
internal extension IQKeyboardManager {

    private struct AssociatedKeys {
        static var textFieldView: Int = 0
        static var rootControllerConfiguration: Int = 0
        static var rootControllerConfigurationWhilePopGestureRecognizerActive: Int = 0
    }

    /** To save UITextField/UITextView object voa textField/textView notifications. */
    weak var textFieldView: UIView? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.textFieldView) as? WeakObjectContainer)?.object as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.textFieldView, WeakObjectContainer(object: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var rootControllerConfiguration: IQRootControllerConfiguration? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.rootControllerConfiguration) as? IQRootControllerConfiguration
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.rootControllerConfiguration, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var rootControllerConfigurationWhilePopGestureRecognizerActive: IQRootControllerConfiguration? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.rootControllerConfigurationWhilePopGestureRecognizerActive) as? IQRootControllerConfiguration
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.rootControllerConfigurationWhilePopGestureRecognizerActive, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
    @objc func textFieldViewDidBeginEditing(_ notification: Notification) {

        guard let object = notification.object as? UIView, let isKeyWindow = object.window?.isKeyWindow, isKeyWindow else {
            return
        }

        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog("📝>>>>> \(#function) started >>>>>", indentation: 1)
        showLog("Notification Object:\(notification.object ?? "NULL")")

        //  Getting object
        textFieldView = notification.object as? UIView

        if keyboardConfiguration.overrideAppearance,
           let textInput: UITextInput = textFieldView as? UITextInput,
            textInput.keyboardAppearance != keyboardConfiguration.appearance {
            // Setting textField keyboard appearance and reloading inputViews.
            if let textFieldView: UITextField = textFieldView as? UITextField {
                textFieldView.keyboardAppearance = keyboardConfiguration.appearance
            } else if  let textFieldView: UITextView = textFieldView as? UITextView {
                textFieldView.keyboardAppearance = keyboardConfiguration.appearance
            }
            textFieldView?.reloadInputViews()
        }

        // If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
        if privateIsEnableAutoToolbar() {

            // UITextView special case. Keyboard Notification is firing before textView notification so we need to resign it first and then again set it as first responder to add toolbar on it.
            if let textView: UIScrollView = textFieldView as? UIScrollView,
                textView.responds(to: #selector(getter: UITextView.isEditable)),
                textView.inputAccessoryView == nil {

                UIView.animate(withDuration: 0.00001, delay: 0, options: .curveLinear, animations: { () -> Void in

                    self.addToolbarIfRequired()

                }, completion: { (_) -> Void in

                    // On textView toolbar didn't appear on first time, so forcing textView to reload it's inputViews.
                    textView.reloadInputViews()
                })
            } else {
                // Adding toolbar
                addToolbarIfRequired()
            }
        } else {
            removeToolbarIfRequired()
        }

        resignFirstResponderGesture.isEnabled = privateShouldResignOnTouchOutside()
        textFieldView?.window?.addGestureRecognizer(resignFirstResponderGesture)    //   (Enhancement ID: #14)

        if !privateIsEnabled() {
            restorePosition()
            rootControllerConfiguration = nil
        } else {
            if rootControllerConfiguration == nil {    //  (Bug ID: #5)

                if let controller: UIViewController = textFieldView?.iq.parentContainerViewController() {

                    if rootControllerConfigurationWhilePopGestureRecognizerActive?.rootController == controller {
                        rootControllerConfiguration = rootControllerConfigurationWhilePopGestureRecognizerActive
                    } else {
                        rootControllerConfiguration = .init(rootController: controller)
                    }

                    rootControllerConfigurationWhilePopGestureRecognizerActive = nil

                    if let rootControllerConfiguration = rootControllerConfiguration {
                        self.showLog("Saving \(rootControllerConfiguration.rootController) beginning origin: \(rootControllerConfiguration.beginOrigin)")
                    }
                }
            }

            // If textFieldView is inside ignored responder then do nothing. (Bug ID: #37, #74, #76)
            // See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).
            if keyboardInfo.keyboardShowing,
               let textFieldView: UIView = textFieldView,
                !textFieldView.iq.isAlertViewTextField() {

                //  keyboard is already showing. adjust position.
                optimizedAdjustPosition()
            }
        }

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("📝<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    /**  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
    @objc func textFieldViewDidEndEditing(_ notification: Notification) {

        guard let object: UIView = notification.object as? UIView, let isKeyWindow = object.window?.isKeyWindow, isKeyWindow else {
            return
        }

        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog("📝>>>>> \(#function) started >>>>>", indentation: 1)
        showLog("Notification Object:\(notification.object ?? "NULL")")

        // Removing gesture recognizer   (Enhancement ID: #14)
        textFieldView?.window?.removeGestureRecognizer(resignFirstResponderGesture)

        if let startingTextViewConfiguration = startingTextViewConfiguration,
           startingTextViewConfiguration.hasChanged {

            if startingTextViewConfiguration.scrollView.contentInset != startingTextViewConfiguration.startingContentInsets {
                showLog("Restoring textView.contentInset to: \(startingTextViewConfiguration.startingContentInsets)")
            }

            keyboardInfo.animate(alongsideTransition: {
                startingTextViewConfiguration.restore(for: self.textFieldView)
            })
        }
        startingTextViewConfiguration = nil

        // Setting object to nil
#if swift(>=5.7)
        if #available(iOS 16.0, *), let textView = object as? UITextView, textView.isFindInteractionEnabled {
                // Not setting it nil, because it may be doing find interaction.
                // As of now, here textView.findInteraction?.isFindNavigatorVisible returns false
                // So there is no way to detect if this is dismissed due to findInteraction
        } else {
            textFieldView = nil
        }
 #else
        textFieldView = nil
#endif

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("📝<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }
}
