//
//  IQKeyboardManager+UIKeyboardNotification.swift
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

// MARK: UIKeyboard Notifications
@available(iOSApplicationExtension, unavailable)
internal extension IQKeyboardManager {

    func handleKeyboardTextFieldViewVisible() {
        if self.activeConfiguration.rootControllerConfiguration == nil {    //  (Bug ID: #5)

            let rootConfiguration: IQRootControllerConfiguration? = self.activeConfiguration.rootControllerConfiguration
            if let gestureConfiguration = self.rootConfigurationWhilePopGestureActive,
               gestureConfiguration.rootController == rootConfiguration?.rootController {
                self.activeConfiguration.rootControllerConfiguration = gestureConfiguration
            }

            self.rootConfigurationWhilePopGestureActive = nil

            if let configuration = self.activeConfiguration.rootControllerConfiguration {
                let classNameString: String = "\(type(of: configuration.rootController.self))"
                self.showLog("Saving \(classNameString) beginning origin: \(configuration.beginOrigin)")
            }
        }

        setupTextFieldView()

        if !privateIsEnabled() {
            restorePosition()
        } else {
            adjustPosition()
        }
    }

    func handleKeyboardTextFieldViewChanged() {

        setupTextFieldView()

        if !privateIsEnabled() {
            restorePosition()
        } else {
            adjustPosition()
        }
    }

    func handleKeyboardTextFieldViewHide() {

        self.restorePosition()
        self.banishTextFieldViewSetup()

        if let configuration = self.activeConfiguration.rootControllerConfiguration,
           configuration.rootController.navigationController?.interactivePopGestureRecognizer?.state == .began {
            self.rootConfigurationWhilePopGestureActive = configuration
        }

        self.lastScrollViewConfiguration = nil
    }
}

@available(iOSApplicationExtension, unavailable)
internal extension IQKeyboardManager {

    func setupTextFieldView() {

        guard let textFieldView = activeConfiguration.textFieldViewInfo?.textFieldView else {
            return
        }

        do {
            if let startingConfiguration = startingTextViewConfiguration,
               startingConfiguration.hasChanged {

                if startingConfiguration.scrollView.contentInset != startingConfiguration.startingContentInset {
                    showLog("Restoring textView.contentInset to: \(startingConfiguration.startingContentInset)")
                }

                activeConfiguration.animate(alongsideTransition: {
                    startingConfiguration.restore(for: textFieldView)
                })
            }
            startingTextViewConfiguration = nil
        }

        if keyboardConfiguration.overrideAppearance,
           let textInput: UITextInput = textFieldView as? UITextInput,
            textInput.keyboardAppearance != keyboardConfiguration.appearance {
            // Setting textField keyboard appearance and reloading inputViews.
            if let textFieldView: UITextField = textFieldView as? UITextField {
                textFieldView.keyboardAppearance = keyboardConfiguration.appearance
            } else if  let textFieldView: UITextView = textFieldView as? UITextView {
                textFieldView.keyboardAppearance = keyboardConfiguration.appearance
            }
            textFieldView.reloadInputViews()
        }

        // If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
        reloadInputViews()

        resignFirstResponderGesture.isEnabled = privateResignOnTouchOutside()
        textFieldView.window?.addGestureRecognizer(resignFirstResponderGesture)    //   (Enhancement ID: #14)
    }

    func banishTextFieldViewSetup() {

        guard let textFieldView = activeConfiguration.textFieldViewInfo?.textFieldView else {
            return
        }

        // Removing gesture recognizer   (Enhancement ID: #14)
        textFieldView.window?.removeGestureRecognizer(resignFirstResponderGesture)

        do {
            if let startingConfiguration = startingTextViewConfiguration,
               startingConfiguration.hasChanged {

                if startingConfiguration.scrollView.contentInset != startingConfiguration.startingContentInset {
                    showLog("Restoring textView.contentInset to: \(startingConfiguration.startingContentInset)")
                }

                activeConfiguration.animate(alongsideTransition: {
                    startingConfiguration.restore(for: textFieldView)
                })
            }
            startingTextViewConfiguration = nil
        }
    }
}
