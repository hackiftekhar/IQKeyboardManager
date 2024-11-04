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
import IQKeyboardToolbarManager

@available(iOSApplicationExtension, unavailable)
// swiftlint:disable line_length
@available(*, deprecated,
            message: "Please use `IQKeyboardToolbarManager` independently from https://github.com/hackiftekhar/IQKeyboardToolbarManager")
// swiftlint:enable line_length
@MainActor
@objc public extension IQKeyboardManager {

    @MainActor
    private struct AssociatedKeys {
        static var toolbarManager: Int = 0
    }

    internal var toolbarManager: IQKeyboardToolbarManager {
        IQKeyboardToolbarManager.shared
    }

    var enableToolbarDebugging: Bool {
        get { toolbarManager.isDebuggingEnabled }
        set { toolbarManager.isDebuggingEnabled = newValue }
    }

    /**
     Automatic add the toolbar functionality. Default is YES.
     */
    var enableAutoToolbar: Bool {
        get { toolbarManager.isEnabled }
        set { toolbarManager.isEnabled = newValue }
    }

    /**
     Configurations related to the toolbar display over the keyboard.
     */
    var toolbarConfiguration: IQKeyboardToolbarConfiguration {
        toolbarManager.toolbarConfiguration
    }

    // MARK: UISound handling

    /**
     If YES, then it plays inputClick sound on next/previous/done click.
     */
    var playInputClicks: Bool {
        get { toolbarManager.playInputClicks }
        set { toolbarManager.playInputClicks = newValue }
    }

    /**
     Disable automatic toolbar creation within the scope of disabled toolbar viewControllers classes.
     Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     */
    var disabledToolbarClasses: [UIViewController.Type] {
        get { toolbarManager.disabledToolbarClasses }
        set { toolbarManager.disabledToolbarClasses = newValue }
    }

    /**
     Enable automatic toolbar creation within the scope of enabled toolbar viewControllers classes.
     Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     If same Class is added in disabledToolbarClasses list, then enabledToolbarClasses will be ignore.
     */
    var enabledToolbarClasses: [UIViewController.Type] {
        get { toolbarManager.enabledToolbarClasses }
        set { toolbarManager.enabledToolbarClasses = newValue }
    }

    /**
     Allowed subclasses of UIView to add all inner textField,
     this will allow to navigate between textField contains in different superview.
     Class should be kind of UIView.
     */
    var deepResponderAllowedContainerClasses: [UIView.Type] {
        get { toolbarManager.deepResponderAllowedContainerClasses }
        set { toolbarManager.deepResponderAllowedContainerClasses = newValue }
    }

    /**    reloadInputViews to reload toolbar buttons enable/disable state on the fly Enhancement ID #434. */
    func reloadInputViews() {
        toolbarManager.reloadInputViews()
    }

    /**
     Returns YES if can navigate to previous responder textInputView, otherwise NO.
     */
    var canGoPrevious: Bool {
        toolbarManager.canGoPrevious
    }

    /**
     Returns YES if can navigate to next responder textInputViews, otherwise NO.
     */
    var canGoNext: Bool {
        toolbarManager.canGoNext
    }

    /**
     Navigate to previous responder textInputViews
    */
    @discardableResult
    func goPrevious() -> Bool {
        toolbarManager.goPrevious()
    }

    /**
     Navigate to next responder textInputView.
    */
    @discardableResult
    func goNext() -> Bool {
        toolbarManager.goNext()
    }
}
