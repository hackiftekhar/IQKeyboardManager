//
//  UIView+Parent.swift
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

/**
UIView hierarchy category.
*/

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardExtension where Base: UIView {

    /**
     Returns the UIViewController object that is actually the parent of this object.
     Most of the time it's the viewController object which actually contains it,
     but result may be different if it's viewController is added as childViewController of another viewController.
     */
    func parentContainerViewController() -> UIViewController? {

        var matchController: UIViewController? = viewContainingController()
        var parentContainerViewController: UIViewController?

        if var navController: UINavigationController = matchController?.navigationController {

            while let parentNav: UINavigationController = navController.navigationController {
                navController = parentNav
            }

            var parentController: UIViewController = navController

            while let parent: UIViewController = parentController.parent,
                  !(parent is UINavigationController) &&
                   !(parent is UITabBarController) &&
                   !(parent is UISplitViewController) {

                        parentController = parent
            }

            if navController == parentController {
                parentContainerViewController = navController.topViewController
            } else {
                parentContainerViewController = parentController
            }
        } else if let tabController: UITabBarController = matchController?.tabBarController {
            let selectedController = tabController.selectedViewController
            if let navController: UINavigationController = selectedController as? UINavigationController {
                parentContainerViewController = navController.topViewController
            } else {
                parentContainerViewController = tabController.selectedViewController
            }
        } else {
            while let parent: UIViewController = matchController?.parent,
                  !(parent is UINavigationController) &&
                   !(parent is UITabBarController) &&
                   !(parent is UISplitViewController) {

                        matchController = parent
            }

            parentContainerViewController = matchController
        }

        if let controller: UIViewController = parentContainerViewController?.iq_parentContainerViewController() {
            return controller
        } else {
            return parentContainerViewController
        }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension UIView {

    @available(*, unavailable, renamed: "iq.parentContainerViewController()")
    func parentContainerViewController() -> UIViewController? { nil }
}
