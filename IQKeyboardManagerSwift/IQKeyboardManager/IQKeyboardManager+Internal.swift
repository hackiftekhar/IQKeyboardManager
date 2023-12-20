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

@available(iOSApplicationExtension, unavailable)
internal extension IQKeyboardManager {

    /**    Get all UITextField/UITextView siblings of textFieldView. */
    func responderViews() -> [UIView]? {

        guard let textFieldView: UIView = activeConfiguration.textFieldViewInfo?.textFieldView else {
            return nil
        }

        var superConsideredView: UIView?

        // If find any consider responderView in it's upper hierarchy then will get deepResponderView.
        for allowedClass in toolbarPreviousNextAllowedClasses {
            superConsideredView = textFieldView.iq.superviewOf(type: allowedClass)
            if superConsideredView != nil {
                break
            }
        }

        var swiftUIHostingView: UIView?
        let swiftUIHostingViewName: String = "UIHostingView<"
        var superView: UIView? = textFieldView.superview
        while let unwrappedSuperView: UIView = superView {

            let classNameString: String = {
                var name: String = "\(type(of: unwrappedSuperView.self))"
                if name.hasPrefix("_") {
                    name.removeFirst()
                }
                return name
            }()

            if classNameString.hasPrefix(swiftUIHostingViewName) {
                swiftUIHostingView = unwrappedSuperView
                break
            }

            superView = unwrappedSuperView.superview
        }

        // (Enhancement ID: #22)
        // If there is a superConsideredView in view's hierarchy,
        // then fetching all it's subview that responds.
        // No sorting for superConsideredView, it's by subView position.
        if let view: UIView = swiftUIHostingView {
            return view.iq.deepResponderViews()
        } else if let view: UIView = superConsideredView {
            return view.iq.deepResponderViews()
        } else {  // Otherwise fetching all the siblings

            let textFields: [UIView] = textFieldView.iq.responderSiblings()

            // Sorting textFields according to behavior
            switch toolbarConfiguration.manageBehavior {
            // If autoToolbar behavior is bySubviews, then returning it.
            case .bySubviews:   return textFields

            // If autoToolbar behavior is by tag, then sorting it according to tag property.
            case .byTag:    return textFields.sortedByTag()

            // If autoToolbar behavior is by tag, then sorting it according to tag property.
            case .byPosition:    return textFields.sortedByPosition()
            }
        }
    }

    func privateIsEnabled() -> Bool {

        var isEnabled: Bool = enable

        guard let textFieldViewInfo: IQTextFieldViewInfo = activeConfiguration.textFieldViewInfo else {
            return isEnabled
        }

        let enableMode: IQEnableMode = textFieldViewInfo.textFieldView.iq.enableMode

        if enableMode == .enabled {
            isEnabled = true
        } else if enableMode == .disabled {
            isEnabled = false
        } else if var textFieldViewController = textFieldViewInfo.textFieldView.iq.viewContainingController() {

            // If it is searchBar textField embedded in Navigation Bar
            if textFieldViewInfo.textFieldView.iq.textFieldSearchBar() != nil,
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
                    if classNameString.contains("UIAlertController"),
                       classNameString.hasSuffix("TextFieldViewController") {
                        isEnabled = false
                    }
                }
            }
        }

        return isEnabled
    }

    func privateIsEnableAutoToolbar() -> Bool {

        var isEnabled: Bool = enableAutoToolbar

        guard let textFieldViewInfo: IQTextFieldViewInfo = activeConfiguration.textFieldViewInfo,
              var textFieldViewController = textFieldViewInfo.textFieldView.iq.viewContainingController() else {
            return isEnabled
        }

        // If it is searchBar textField embedded in Navigation Bar
        if textFieldViewInfo.textFieldView.iq.textFieldSearchBar() != nil,
           let navController: UINavigationController = textFieldViewController as? UINavigationController,
           let topController: UIViewController = navController.topViewController {
            textFieldViewController = topController
        }

        if !isEnabled, enabledToolbarClasses.contains(where: { textFieldViewController.isKind(of: $0) }) {
            isEnabled = true
        }

        if isEnabled {

            // If found any toolbar disabled classes then return.
            if disabledToolbarClasses.contains(where: { textFieldViewController.isKind(of: $0) }) {
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

        return isEnabled
    }

    func privateResignOnTouchOutside() -> Bool {

        var isEnabled: Bool = resignOnTouchOutside

        guard let textFieldViewInfo: IQTextFieldViewInfo = activeConfiguration.textFieldViewInfo else {
            return isEnabled
        }

        let enableMode: IQEnableMode = textFieldViewInfo.textFieldView.iq.resignOnTouchOutsideMode

        if enableMode == .enabled {
            isEnabled = true
        } else if enableMode == .disabled {
            isEnabled = false
        } else if var textFieldViewController = textFieldViewInfo.textFieldView.iq.viewContainingController() {

            // If it is searchBar textField embedded in Navigation Bar
            if textFieldViewInfo.textFieldView.iq.textFieldSearchBar() != nil,
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
