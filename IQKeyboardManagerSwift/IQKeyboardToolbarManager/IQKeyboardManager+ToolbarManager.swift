//
//  IQKeyboardManager+ToolbarManager.swift
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
public extension IQKeyboardManager {

    @MainActor
    private struct AssociatedKeys {
        static var toolbarManager: Int = 0
    }

    @objc internal var toolbarManager: IQKeyboardToolbarManager {
        if let object = objc_getAssociatedObject(self, &AssociatedKeys.toolbarManager)
            as? IQKeyboardToolbarManager {
            return object
        }

        let object: IQKeyboardToolbarManager = .init()
        objc_setAssociatedObject(self, &AssociatedKeys.toolbarManager,
                                 object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return object
    }

    /**
    Automatic add the IQToolbar functionality. Default is YES.
    */
    @objc var enableAutoToolbar: Bool {
        get { toolbarManager.enable }
        set { toolbarManager.enable = newValue }
    }

    /**
    Configurations related to the toolbar display over the keyboard.
    */
    @objc var toolbarConfiguration: IQToolbarConfiguration {
        toolbarManager.toolbarConfiguration
    }

    // MARK: UISound handling

    /**
    If YES, then it plays inputClick sound on next/previous/done click.
    */
    @objc var playInputClicks: Bool {
        get { toolbarManager.playInputClicks }
        set { toolbarManager.playInputClicks = newValue }
    }

    /**
     Disable automatic toolbar creation within the scope of disabled toolbar viewControllers classes.
     Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     */
    @objc var disabledToolbarClasses: [UIViewController.Type] {
        get { toolbarManager.disabledToolbarClasses }
        set { toolbarManager.disabledToolbarClasses = newValue }
    }

    /**
     Enable automatic toolbar creation within the scope of enabled toolbar viewControllers classes.
     Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     If same Class is added in disabledToolbarClasses list, then enabledToolbarClasses will be ignore.
     */
    @objc var enabledToolbarClasses: [UIViewController.Type] {
        get { toolbarManager.enabledToolbarClasses }
        set { toolbarManager.enabledToolbarClasses = newValue }
    }

    /**
     Allowed subclasses of UIView to add all inner textField,
     this will allow to navigate between textField contains in different superview.
     Class should be kind of UIView.
     */
    @objc var deepResponderAllowedContainerClasses: [UIView.Type] {
        get { toolbarManager.deepResponderAllowedContainerClasses }
        set { toolbarManager.deepResponderAllowedContainerClasses = newValue }
    }

    /**    reloadInputViews to reload toolbar buttons enable/disable state on the fly Enhancement ID #434. */
    @objc func reloadInputViews() {
        toolbarManager.reloadInputViews()
    }
}
