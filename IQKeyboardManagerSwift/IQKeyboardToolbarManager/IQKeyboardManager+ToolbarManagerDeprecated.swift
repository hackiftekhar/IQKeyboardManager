//
//  IQKeyboardManager+ToolbarManagerDeprecated.swift
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

// swiftlint:disable unused_setter_value
// swiftlint:disable identifier_name
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardManager {

    @available(*, unavailable, renamed: "playInputClicks")
    var shouldPlayInputClicks: Bool {
        get { false }
        set { }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardManager {

    @available(*, unavailable, renamed: "toolbarConfiguration.manageBehavior")
    var toolbarManageBehaviour: IQKeyboardToolbarManageBehavior {
        get { .bySubviews }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.useTextInputViewTintColor")
    var shouldToolbarUsesTextFieldTintColor: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.tintColor")
    var toolbarTintColor: UIColor? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.barTintColor")
    var toolbarBarTintColor: UIColor? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.previousNextDisplayMode")
    var previousNextDisplayMode: IQPreviousNextDisplayMode {
        get { .default }
        set { }
    }

    @available(*, unavailable, renamed: "deepResponderAllowedContainerClasses")
    var toolbarPreviousNextAllowedClasses: [UIView.Type] {
        get { [] }
        set { }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardManager {
    @available(*, unavailable, renamed: "toolbarConfiguration.previousBarButtonConfiguration.image",
                message: "To change, please assign a new toolbarConfiguration.previousBarButtonConfiguration")
    var toolbarPreviousBarButtonItemImage: UIImage? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.previousBarButtonConfiguration.title",
                message: "To change, please assign a new toolbarConfiguration.previousBarButtonConfiguration")
    var toolbarPreviousBarButtonItemText: String? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.previousBarButtonConfiguration.accessibilityLabel",
                message: "To change, please assign a new toolbarConfiguration.previousBarButtonConfiguration")
    var toolbarPreviousBarButtonItemAccessibilityLabel: String? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.nextBarButtonConfiguration.image",
                message: "To change, please assign a new toolbarConfiguration.nextBarButtonConfiguration")
    var toolbarNextBarButtonItemImage: UIImage? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.nextBarButtonConfiguration.title",
                message: "To change, please assign a new toolbarConfiguration.nextBarButtonConfiguration")
    var toolbarNextBarButtonItemText: String? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.nextBarButtonConfiguration.accessibilityLabel",
                message: "To change, please assign a new toolbarConfiguration.nextBarButtonConfiguration")
    var toolbarNextBarButtonItemAccessibilityLabel: String? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.doneBarButtonConfiguration.image",
                message: "To change, please assign a new toolbarConfiguration.doneBarButtonConfiguration")
    var toolbarDoneBarButtonItemImage: UIImage? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.doneBarButtonConfiguration.title",
                message: "To change, please assign a new toolbarConfiguration.doneBarButtonConfiguration")
    var toolbarDoneBarButtonItemText: String? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.doneBarButtonConfiguration.accessibilityLabel",
                message: "To change, please assign a new toolbarConfiguration.doneBarButtonConfiguration")
    var toolbarDoneBarButtonItemAccessibilityLabel: String? {
        get { nil }
        set { }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardManager {

    @available(*, unavailable, renamed: "toolbarConfiguration.placeholderConfiguration.accessibilityLabel")
    var toolbarTitleBarButtonItemAccessibilityLabel: String? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.placeholderConfiguration.showPlaceholder")
    var shouldShowToolbarPlaceholder: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.placeholderConfiguration.font")
    var placeholderFont: UIFont? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.placeholderConfiguration.color")
    var placeholderColor: UIColor? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.placeholderConfiguration.buttonColor")
    var placeholderButtonColor: UIColor? {
        get { nil }
        set { }
    }
}
// swiftlint:enable unused_setter_value
// swiftlint:enable identifier_name
