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

import Foundation

internal extension IQKeyboardManager {

    /**    Get all UITextField/UITextView siblings of textFieldView. */
    func responderViews() -> [UIView]? {

        var superConsideredView: UIView?

        //If find any consider responderView in it's upper hierarchy then will get deepResponderView.
        for disabledClass in toolbarPreviousNextAllowedClasses {

            superConsideredView = textFieldView?.superviewOfClassType(disabledClass)

            if superConsideredView != nil {
                break
            }
        }

        //If there is a superConsideredView in view's hierarchy, then fetching all it's subview that responds. No sorting for superConsideredView, it's by subView position.    (Enhancement ID: #22)
        if let view = superConsideredView {
            return view.deepResponderViews()
        } else {  //Otherwise fetching all the siblings

            if let textFields = textFieldView?.responderSiblings() {

                //Sorting textFields according to behaviour
                switch toolbarManageBehaviour {
                //If autoToolbar behaviour is bySubviews, then returning it.
                case .bySubviews:   return textFields

                //If autoToolbar behaviour is by tag, then sorting it according to tag property.
                case .byTag:    return textFields.sortedArrayByTag()

                //If autoToolbar behaviour is by tag, then sorting it according to tag property.
                case .byPosition:    return textFields.sortedArrayByPosition()
                }
            } else {
                return nil
            }
        }
    }

    func privateIsEnabled() -> Bool {

        var isEnabled = enable

        let enableMode = textFieldView?.enableMode

        if enableMode == .enabled {
            isEnabled = true
        } else if enableMode == .disabled {
            isEnabled = false
        } else {
            if var textFieldViewController = textFieldView?.viewContainingController() {

                //If it is searchBar textField embedded in Navigation Bar
                if textFieldView?.textFieldSearchBar() != nil, let navController = textFieldViewController as? UINavigationController, let topController = navController.topViewController {
                    textFieldViewController = topController
                }

                if isEnabled == false {

                    //If viewController is kind of enable viewController class, then assuming it's enabled.
                    for enabledClass in enabledDistanceHandlingClasses {

                        if textFieldViewController.isKind(of: enabledClass) {
                            isEnabled = true
                            break
                        }
                    }
                }

                if isEnabled == true {

                    //If viewController is kind of disabled viewController class, then assuming it's disabled.
                    for disabledClass in disabledDistanceHandlingClasses {

                        if textFieldViewController.isKind(of: disabledClass) {
                            isEnabled = false
                            break
                        }
                    }

                    //Special Controllers
                    if isEnabled == true {

                        let classNameString = NSStringFromClass(type(of: textFieldViewController.self))

                        //_UIAlertControllerTextFieldViewController
                        if classNameString.contains("UIAlertController") && classNameString.hasSuffix("TextFieldViewController") {
                            isEnabled = false
                        }
                    }
                }
            }
        }

        return isEnabled
    }

    func privateIsEnableAutoToolbar() -> Bool {

        var enableToolbar = enableAutoToolbar

        if var textFieldViewController = textFieldView?.viewContainingController() {

            //If it is searchBar textField embedded in Navigation Bar
            if textFieldView?.textFieldSearchBar() != nil, let navController = textFieldViewController as? UINavigationController, let topController = navController.topViewController {
                textFieldViewController = topController
            }

            if enableToolbar == false {

                //If found any toolbar enabled classes then return.
                for enabledClass in enabledToolbarClasses {

                    if textFieldViewController.isKind(of: enabledClass) {
                        enableToolbar = true
                        break
                    }
                }
            }

            if enableToolbar == true {

                //If found any toolbar disabled classes then return.
                for disabledClass in disabledToolbarClasses {

                    if textFieldViewController.isKind(of: disabledClass) {
                        enableToolbar = false
                        break
                    }
                }

                //Special Controllers
                if enableToolbar == true {

                    let classNameString = NSStringFromClass(type(of: textFieldViewController.self))

                    //_UIAlertControllerTextFieldViewController
                    if classNameString.contains("UIAlertController") && classNameString.hasSuffix("TextFieldViewController") {
                        enableToolbar = false
                    }
                }
            }
        }

        return enableToolbar
    }

    func privateShouldResignOnTouchOutside() -> Bool {

        var shouldResign = shouldResignOnTouchOutside

        let enableMode = textFieldView?.shouldResignOnTouchOutsideMode

        if enableMode == .enabled {
            shouldResign = true
        } else if enableMode == .disabled {
            shouldResign = false
        } else {
            if var textFieldViewController = textFieldView?.viewContainingController() {

                //If it is searchBar textField embedded in Navigation Bar
                if textFieldView?.textFieldSearchBar() != nil, let navController = textFieldViewController as? UINavigationController, let topController = navController.topViewController {
                    textFieldViewController = topController
                }

                if shouldResign == false {

                    //If viewController is kind of enable viewController class, then assuming shouldResignOnTouchOutside is enabled.
                    for enabledClass in enabledTouchResignedClasses {

                        if textFieldViewController.isKind(of: enabledClass) {
                            shouldResign = true
                            break
                        }
                    }
                }

                if shouldResign == true {

                    //If viewController is kind of disable viewController class, then assuming shouldResignOnTouchOutside is disable.
                    for disabledClass in disabledTouchResignedClasses {

                        if textFieldViewController.isKind(of: disabledClass) {
                            shouldResign = false
                            break
                        }
                    }

                    //Special Controllers
                    if shouldResign == true {

                        let classNameString = NSStringFromClass(type(of: textFieldViewController.self))

                        //_UIAlertControllerTextFieldViewController
                        if classNameString.contains("UIAlertController") && classNameString.hasSuffix("TextFieldViewController") {
                            shouldResign = false
                        }
                    }
                }
            }
        }

        return shouldResign
    }
}
