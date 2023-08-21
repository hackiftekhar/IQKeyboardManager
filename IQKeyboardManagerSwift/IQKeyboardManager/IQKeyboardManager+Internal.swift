//
//  IQKeyboardManager+Internal.swift
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

@available(iOSApplicationExtension, unavailable)
internal extension IQKeyboardManager {

    /**    Get all UITextField/UITextView siblings of textFieldView. */
    func responderViews() -> [UIView]? {

        var superConsideredView: UIView?

        // If find any consider responderView in it's upper hierarchy then will get deepResponderView.
        for disabledClass in toolbarPreviousNextAllowedClasses {
            superConsideredView = textFieldView?.iq.superviewOf(type: disabledClass)
            if superConsideredView != nil {
                break
            }
        }

        // If there is a superConsideredView in view's hierarchy, then fetching all it's subview that responds. No sorting for superConsideredView, it's by subView position.    (Enhancement ID: #22)
        if let view: UIView = superConsideredView {
            return view.iq.deepResponderViews()
        } else {  // Otherwise fetching all the siblings

            guard let textFields: [UIView] = textFieldView?.iq.responderSiblings() else {
                return nil
            }

            // Sorting textFields according to behaviour
            switch toolbarConfiguration.manageBehaviour {
            // If autoToolbar behaviour is bySubviews, then returning it.
            case .bySubviews:   return textFields

            // If autoToolbar behaviour is by tag, then sorting it according to tag property.
            case .byTag:    return textFields.sortedByTag()

            // If autoToolbar behaviour is by tag, then sorting it according to tag property.
            case .byPosition:    return textFields.sortedByPosition()
            }
        }
    }

    func privateIsEnabled() -> Bool {

        var isEnabled: Bool = enable

        let enableMode: IQEnableMode? = textFieldView?.iq.enableMode

        if enableMode == .enabled {
            isEnabled = true
        } else if enableMode == .disabled {
            isEnabled = false
        } else if var textFieldViewController: UIViewController = textFieldView?.iq.viewContainingController() {

            // If it is searchBar textField embedded in Navigation Bar
            if textFieldView?.iq.textFieldSearchBar() != nil,
               let navController: UINavigationController = textFieldViewController as? UINavigationController,
               let topController: UIViewController = navController.topViewController {
                textFieldViewController = topController
            }

            // If viewController is kind of enable viewController class, then assuming it's enabled.
            if !isEnabled, enabledDistanceHandlingClasses.contains(where: { textFieldViewController.isKind(of: $0) }) {
                isEnabled = true
            }

            if isEnabled {

                // If viewController is kind of disabled viewController class, then assuming it's disabled.
                if disabledDistanceHandlingClasses.contains(where: { textFieldViewController.isKind(of: $0) }) {
                    isEnabled = false
                }

                // Special Controllers
                if isEnabled {

                    let classNameString: String = "\(type(of: textFieldViewController.self))"

                    // _UIAlertControllerTextFieldViewController
                    if classNameString.contains("UIAlertController"), classNameString.hasSuffix("TextFieldViewController") {
                        isEnabled = false
                    }
                }
            }
        }

        return isEnabled
    }

    func privateIsEnableAutoToolbar() -> Bool {

        guard var textFieldViewController: UIViewController = textFieldView?.iq.viewContainingController() else {
            return enableAutoToolbar
        }

        // If it is searchBar textField embedded in Navigation Bar
        if textFieldView?.iq.textFieldSearchBar() != nil,
           let navController: UINavigationController = textFieldViewController as? UINavigationController,
           let topController: UIViewController = navController.topViewController {
            textFieldViewController = topController
        }

        var enableToolbar: Bool = enableAutoToolbar

        if !enableToolbar, enabledToolbarClasses.contains(where: { textFieldViewController.isKind(of: $0) }) {
            enableToolbar = true
        }

        if enableToolbar {

            // If found any toolbar disabled classes then return.
            if disabledToolbarClasses.contains(where: { textFieldViewController.isKind(of: $0) }) {
                enableToolbar = false
            }

            // Special Controllers
            if enableToolbar {

                let classNameString: String = "\(type(of: textFieldViewController.self))"

                // _UIAlertControllerTextFieldViewController
                if classNameString.contains("UIAlertController"), classNameString.hasSuffix("TextFieldViewController") {
                    enableToolbar = false
                }
            }
        }

        return enableToolbar
    }

    func privateResignOnTouchOutside() -> Bool {

        var resignOnTouchOutside: Bool = resignOnTouchOutside

        let enableMode: IQEnableMode? = textFieldView?.iq.resignOnTouchOutsideMode

        if enableMode == .enabled {
            resignOnTouchOutside = true
        } else if enableMode == .disabled {
            resignOnTouchOutside = false
        } else if var textFieldViewController = textFieldView?.iq.viewContainingController() {

            // If it is searchBar textField embedded in Navigation Bar
            if textFieldView?.iq.textFieldSearchBar() != nil,
               let navController: UINavigationController = textFieldViewController as? UINavigationController,
               let topController: UIViewController = navController.topViewController {
                textFieldViewController = topController
            }

            // If viewController is kind of enable viewController class, then assuming resignOnTouchOutside is enabled.
            if !resignOnTouchOutside,
               enabledTouchResignedClasses.contains(where: { textFieldViewController.isKind(of: $0) }) {
                resignOnTouchOutside = true
            }

            if resignOnTouchOutside {

                // If viewController is kind of disable viewController class, then assuming resignOnTouchOutside is disable.
                if disabledTouchResignedClasses.contains(where: { textFieldViewController.isKind(of: $0) }) {
                    resignOnTouchOutside = false
                }

                // Special Controllers
                if resignOnTouchOutside {

                    let classNameString: String = "\(type(of: textFieldViewController.self))"

                    // _UIAlertControllerTextFieldViewController
                    if classNameString.contains("UIAlertController"),
                        classNameString.hasSuffix("TextFieldViewController") {
                        resignOnTouchOutside = false
                    }
                }
            }
        }
        return resignOnTouchOutside
    }
}
