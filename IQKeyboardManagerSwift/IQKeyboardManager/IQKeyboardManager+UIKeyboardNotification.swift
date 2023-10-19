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
//        showLog("⌨️>>>>> \(#function) started >>>>>", indentation: 1)
//        let startTime: CFTimeInterval = CACurrentMediaTime()
//        showLog("UIKeyboard Frame: \(activeConfiguration.keyboardInfo.frame)")

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

//        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
//        showLog("⌨️<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    func handleKeyboardTextFieldViewChanged() {
//        showLog("⌨️>>>>> \(#function) started >>>>>", indentation: 1)
//        let startTime: CFTimeInterval = CACurrentMediaTime()

        setupTextFieldView()

        if !privateIsEnabled() {
            restorePosition()
        } else {
            adjustPosition()
        }

//        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
//        showLog("⌨️<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    func handleKeyboardTextFieldViewHide() {
//        let startTime: CFTimeInterval = CACurrentMediaTime()
//        showLog("⌨️>>>>> \(#function) started >>>>>", indentation: 1)

        self.restorePosition()
        self.benishTextFieldViewSetup()

        if let configuration = self.activeConfiguration.rootControllerConfiguration,
           configuration.rootController.navigationController?.interactivePopGestureRecognizer?.state == .began {
            self.rootConfigurationWhilePopGestureActive = configuration
        }

        self.lastScrollViewConfiguration = nil

//        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
//        showLog("⌨️<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
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

                if startingConfiguration.scrollView.contentInset != startingConfiguration.startingContentInsets {
                    showLog("Restoring textView.contentInset to: \(startingConfiguration.startingContentInsets)")
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
        if privateIsEnableAutoToolbar() {
            addToolbarIfRequired()
        } else {
            removeToolbarIfRequired()
        }

        resignFirstResponderGesture.isEnabled = privateResignOnTouchOutside()
        textFieldView.window?.addGestureRecognizer(resignFirstResponderGesture)    //   (Enhancement ID: #14)
    }

    func benishTextFieldViewSetup() {

        guard let textFieldView = activeConfiguration.textFieldViewInfo?.textFieldView else {
            return
        }

//        let startTime: CFTimeInterval = CACurrentMediaTime()
//        showLog("⌨️>>>>> \(#function) started >>>>>", indentation: 1)

        // Removing gesture recognizer   (Enhancement ID: #14)
        textFieldView.window?.removeGestureRecognizer(resignFirstResponderGesture)

        do {
            if let startingConfiguration = startingTextViewConfiguration,
               startingConfiguration.hasChanged {

                if startingConfiguration.scrollView.contentInset != startingConfiguration.startingContentInsets {
                    showLog("Restoring textView.contentInset to: \(startingConfiguration.startingContentInsets)")
                }

                activeConfiguration.animate(alongsideTransition: {
                    startingConfiguration.restore(for: textFieldView)
                })
            }
            startingTextViewConfiguration = nil
        }

//        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
//        showLog("📝<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }
}
