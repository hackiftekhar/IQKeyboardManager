//
//  IQKeyboardManager+Internal.swift
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
import IQTextInputViewNotification
import IQKeyboardCore

@available(iOSApplicationExtension, unavailable)
@MainActor
internal extension IQKeyboardManager {

    func registerActiveStateChangeForTouchOutside() {
        self.activeConfiguration.registerChange(identifier: "resignOnTouchOutside",
                                                changeHandler: { [weak self] event, _, textFieldInfo in
            guard let self = self else { return }
            switch event {
            case .hide:
                // Removing gesture recognizer (Enhancement ID: #14)
                textFieldInfo?.textInputView.window?.removeGestureRecognizer(resignGesture)
            case .show:
                // Adding gesture recognizer (Enhancement ID: #14)
                textFieldInfo?.textInputView.window?.addGestureRecognizer(resignGesture)

                updateResignGestureState()
            case .change:
                updateResignGestureState()
            }
        })
    }

    func unregisterActiveStateChangeForTouchOutside() {
        self.activeConfiguration.unregisterChange(identifier: "resignOnTouchOutside")
    }

    func updateResignGestureState() {
        resignGesture.isEnabled = privateResignOnTouchOutside()
    }

    private func privateResignOnTouchOutside() -> Bool {

        guard let textFieldViewInfo: IQTextInputViewInfo = activeConfiguration.textInputViewInfo else {
            return resignOnTouchOutside
        }

        switch textFieldViewInfo.textInputView.iq.resignOnTouchOutsideMode {
        case .default:
            guard var controller = textFieldViewInfo.textInputView.iq.viewContainingController() else {
                return resignOnTouchOutside
            }

            // If it is searchBar textField embedded in Navigation Bar
            if textFieldViewInfo.textInputView.iq.textFieldSearchBar() != nil,
               let navController: UINavigationController = controller as? UINavigationController,
               let topController: UIViewController = navController.topViewController {
                controller = topController
            }

            // If viewController is in enabledTouchResignedClasses, then assuming resignOnTouchOutside is enabled.
            let isWithEnabledClass: Bool = enabledTouchResignedClasses.contains(where: { controller.isKind(of: $0) })
            var isEnabled: Bool = resignOnTouchOutside || isWithEnabledClass

            if isEnabled {

                // If viewController is in disabledTouchResignedClasses,
                // then assuming resignOnTouchOutside is disable.
                if disabledTouchResignedClasses.contains(where: { controller.isKind(of: $0) }) {
                    isEnabled = false
                } else {
                    let classNameString: String = "\(type(of: controller.self))"

                    // _UIAlertControllerTextFieldViewController
                    if classNameString.contains("UIAlertController"),
                       classNameString.hasSuffix("TextFieldViewController") {
                        isEnabled = false
                    }
                }
            }
            return isEnabled
        case .enabled:
            return true
        case .disabled:
            return false
        }
    }
}
