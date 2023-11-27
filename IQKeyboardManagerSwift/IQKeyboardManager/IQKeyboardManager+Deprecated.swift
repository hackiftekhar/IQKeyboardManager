//
//  IQKeyboardManager.swift
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

// swiftlint:disable unused_setter_value
// swiftlint:disable identifier_name
// swiftlint:disable line_length
@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    @available(*, unavailable, renamed: "resignOnTouchOutside")
    @objc var shouldResignOnTouchOutside: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, renamed: "playInputClicks")
    @objc var shouldPlayInputClicks: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, message: "This feature has been removed due to few compatibility problems")
    @objc func registerTextFieldViewClass(_ aClass: UIView.Type,
                                          didBeginEditingNotificationName: String,
                                          didEndEditingNotificationName: String) {
    }

    @available(*, unavailable, message: "This feature has been removed due to few compatibility problems")
    @objc func unregisterTextFieldViewClass(_ aClass: UIView.Type,
                                            didBeginEditingNotificationName: String,
                                            didEndEditingNotificationName: String) {
    }
}

@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    @available(*, unavailable, renamed: "toolbarConfiguration.manageBehavior")
    @objc var toolbarManageBehaviour: IQAutoToolbarManageBehavior {
        get { .bySubviews }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.useTextFieldTintColor")
    @objc var shouldToolbarUsesTextFieldTintColor: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.tintColor")
    @objc var toolbarTintColor: UIColor? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.barTintColor")
    @objc var toolbarBarTintColor: UIColor? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.previousNextDisplayMode")
    @objc var previousNextDisplayMode: IQPreviousNextDisplayMode {
        get { .default }
        set { }
    }
}

@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {
    @available(*, unavailable, renamed: "toolbarConfiguration.previousBarButtonConfiguration.image",
                message: "To change, please assign a new toolbarConfiguration.previousBarButtonConfiguration")
    @objc var toolbarPreviousBarButtonItemImage: UIImage? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.previousBarButtonConfiguration.title",
                message: "To change, please assign a new toolbarConfiguration.previousBarButtonConfiguration")
    @objc var toolbarPreviousBarButtonItemText: String? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.previousBarButtonConfiguration.accessibilityLabel",
                message: "To change, please assign a new toolbarConfiguration.previousBarButtonConfiguration")
    @objc var toolbarPreviousBarButtonItemAccessibilityLabel: String? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.nextBarButtonConfiguration.image",
                message: "To change, please assign a new toolbarConfiguration.nextBarButtonConfiguration")
    @objc var toolbarNextBarButtonItemImage: UIImage? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.nextBarButtonConfiguration.title",
                message: "To change, please assign a new toolbarConfiguration.nextBarButtonConfiguration")
    @objc var toolbarNextBarButtonItemText: String? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.nextBarButtonConfiguration.accessibilityLabel",
                message: "To change, please assign a new toolbarConfiguration.nextBarButtonConfiguration")
    @objc var toolbarNextBarButtonItemAccessibilityLabel: String? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.doneBarButtonConfiguration.image",
                message: "To change, please assign a new toolbarConfiguration.doneBarButtonConfiguration")
    @objc var toolbarDoneBarButtonItemImage: UIImage? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.doneBarButtonConfiguration.title",
                message: "To change, please assign a new toolbarConfiguration.doneBarButtonConfiguration")
    @objc var toolbarDoneBarButtonItemText: String? {
        get { nil }
        set { }
    }
    @available(*, unavailable, renamed: "toolbarConfiguration.doneBarButtonConfiguration.accessibilityLabel",
                message: "To change, please assign a new toolbarConfiguration.doneBarButtonConfiguration")
    @objc var toolbarDoneBarButtonItemAccessibilityLabel: String? {
        get { nil }
        set { }
    }
}

@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    @available(*, unavailable, renamed: "toolbarConfiguration.placeholderConfiguration.accessibilityLabel")
    @objc var toolbarTitlBarButtonItemAccessibilityLabel: String? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.placeholderConfiguration.showPlaceholder")
    @objc var shouldShowToolbarPlaceholder: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.placeholderConfiguration.font")
    @objc var placeholderFont: UIFont? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.placeholderConfiguration.color")
    @objc var placeholderColor: UIColor? {
        get { nil }
        set { }
    }

    @available(*, unavailable, renamed: "toolbarConfiguration.placeholderConfiguration.buttonColor")
    @objc var placeholderButtonColor: UIColor? {
        get { nil }
        set { }
    }
}

@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    @available(*, unavailable, renamed: "keyboardConfiguration.overrideAppearance")
    @objc var overrideKeyboardAppearance: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, renamed: "keyboardConfiguration.appearance")
    @objc var keyboardAppearance: UIKeyboardAppearance {
        get { .default }
        set { }
    }
}

@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    typealias SizeBlock = (_ size: CGSize) -> Void

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    @objc func registerKeyboardSizeChange(identifier: AnyHashable, sizeHandler: @escaping SizeBlock) {}

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    @objc func unregisterKeyboardSizeChange(identifier: AnyHashable) {}

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    @objc var keyboardShowing: Bool { false }

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    @objc var keyboardFrame: CGRect { .zero }
}
// swiftlint:enable unused_setter_value
// swiftlint:enable identifier_name
// swiftlint:enable line_length
