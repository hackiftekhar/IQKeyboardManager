//
//  IQKeyboardManager+Internal.swift
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
import IQKeyboardCore

@available(iOSApplicationExtension, unavailable)
@MainActor
internal extension IQKeyboardManager {

    func privateIsEnabled() -> Bool {

        guard let textInputView: any IQTextInputView = activeConfiguration.textInputView else {
            return isEnabled
        }

        switch textInputView.internalEnableMode {
        case .default:
            guard var controller = (textInputView as UIView).iq.viewContainingController() else {
                return isEnabled
            }

            // If it is searchBar textField embedded in Navigation Bar
            if (textInputView as UIView).iq.textFieldSearchBar() != nil,
               let navController: UINavigationController = controller as? UINavigationController,
               let topController: UIViewController = navController.topViewController {
                controller = topController
            }

            // If viewController is in enabledDistanceHandlingClasses, then assuming it's enabled.
            let isWithEnabledClass: Bool = enabledDistanceHandlingClasses.contains(where: { controller.isKind(of: $0) })
            var isEnabled: Bool = isEnabled || isWithEnabledClass

            if isEnabled {
                // If viewController is in disabledDistanceHandlingClasses,
                // then assuming it's disabled.
                if disabledDistanceHandlingClasses.contains(where: { controller.isKind(of: $0) }) {
                    isEnabled = false
                } else {
                    // Special Controllers
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
        @unknown default:
            return false
        }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
fileprivate extension IQTextInputView {
    var internalEnableMode: IQEnableMode {
        return iq.enableMode
    }
}
