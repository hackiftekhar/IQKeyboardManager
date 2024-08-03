//
//  IQKeyboardResignHandler+Internal.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

@available(iOSApplicationExtension, unavailable)
@MainActor
internal extension IQKeyboardResignHandler {

    func removeTextInputViewObserverForResign() {
        textInputViewObserver.unsubscribe(identifier: "TextInputViewObserverForResign")
    }

    func addTextInputViewObserverForResign() {
        textInputViewObserver.subscribe(identifier: "TextInputViewObserverForResign",
                                        changeHandler: { [weak self] info in
            guard let self = self else { return }
            switch info.event {
            case .beginEditing:
                resignFirstResponderGesture.isEnabled = privateResignOnTouchOutside()
                info.textInputView.window?.addGestureRecognizer(resignFirstResponderGesture)
            case .endEditing:
                info.textInputView.window?.removeGestureRecognizer(resignFirstResponderGesture)
            }
        })
    }

    func privateResignOnTouchOutside() -> Bool {

        var isEnabled: Bool = resignOnTouchOutside

        guard let textFieldView: UIView = textInputViewObserver.textInputView else {
            return isEnabled
        }

        let enableMode: IQEnableMode = textFieldView.iq.resignOnTouchOutsideMode

        if enableMode == .enabled {
            isEnabled = true
        } else if enableMode == .disabled {
            isEnabled = false
        } else if var textFieldViewController = textFieldView.iq.viewContainingController() {

            // If it is searchBar textField embedded in Navigation Bar
            if textFieldView.iq.textFieldSearchBar() != nil,
               let navController: UINavigationController = textFieldViewController as? UINavigationController,
               let topController: UIViewController = navController.topViewController {
                textFieldViewController = topController
            }

            // If viewController is kind of enable viewController class, then assuming resignOnTouchOutside is enabled.
            if !isEnabled,
               enabledTouchResignedClasses.contains(where: { textFieldViewController.isKind(of: $0) }) {
                isEnabled = true
            }

            if isEnabled {

                // If viewController is kind of disable viewController class,
                // then assuming resignOnTouchOutside is disable.
                if disabledTouchResignedClasses.contains(where: { textFieldViewController.isKind(of: $0) }) {
                    isEnabled = false
                }

                // Special Controllers
                if isEnabled {

                    let classNameString: String = "\(type(of: textFieldViewController.self))"

                    // _UIAlertControllerTextFieldViewController
                    if classNameString.contains("UIAlertController"),
                        classNameString.hasSuffix("TextFieldViewController") {
                        isEnabled = false
                    }
                }
            }
        }
        return isEnabled
    }
}
