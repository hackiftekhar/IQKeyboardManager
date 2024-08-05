//
//  IQKeyboardManager+Deprecated.swift
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

// swiftlint:disable unused_setter_value
// swiftlint:disable line_length
// swiftlint:disable type_name
@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardManager {

    @available(*, unavailable, renamed: "keyboardDistance")
    @objc var keyboardDistanceFromTextField: CGFloat {
        get { 10 }
        set { }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardManager {

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
@MainActor
public extension IQKeyboardManager {

    typealias SizeBlock = (_ size: CGSize) -> Void

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardNotification, use it directly by creating new instance")
    @objc func registerKeyboardSizeChange(identifier: AnyHashable, sizeHandler: @escaping SizeBlock) {}

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardNotification, use it directly by creating new instance")
    @objc func unregisterKeyboardSizeChange(identifier: AnyHashable) {}

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardNotification, use it directly by creating new instance")
    @objc var keyboardShowing: Bool { false }

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardNotification, use it directly by creating new instance")
    @objc var keyboardFrame: CGRect { .zero }
}

@available(*, unavailable, renamed: "IQKeyboardReturnManager", message: "Please use `IQKeyboardReturnManager` independently from https://github.com/hackiftekhar/IQKeyboardReturnManager")
@MainActor
@objc public final class IQKeyboardReturnKeyHandler: NSObject {}

@available(*, unavailable, renamed: "IQKeyboardNotification", message: "Please use `IQKeyboardNotification` independently from https://github.com/hackiftekhar/IQKeyboardNotification")
@MainActor
@objc public final class IQKeyboardListener: NSObject {}

@available(*, unavailable, renamed: "IQTextInputViewNotification", message: "Please use `IQTextInputViewNotification` independently from https://github.com/hackiftekhar/IQTextInputViewNotification")
@MainActor
@objc public final class IQTextFieldViewListener: NSObject {}

@available(*, unavailable, renamed: "IQDeepResponderContainerView", message: "Please use `IQDeepResponderContainerView` class which is now part of `IQKeyboardToolbarManager` from https://github.com/hackiftekhar/IQKeyboardToolbarManager.")
@MainActor
@objc open class IQPreviousNextView: UIView {}

@available(*, unavailable, message: "Please use `IQKeyboardToolbar` independently https://github.com/hackiftekhar/IQKeyboardToolbar or through `IQKeyboardToolbarManager` from https://github.com/hackiftekhar/IQKeyboardToolbarManager")
@MainActor
@objc public final class IQToolbarPlaceholderConfigurationDeprecated: NSObject {
    @objc public var showPlaceholder: Bool = true
    @objc public var font: UIFont?
    @objc public var color: UIColor?
    @objc public var buttonColor: UIColor?
    public override var accessibilityLabel: String? { didSet { } }
}

@available(iOSApplicationExtension, unavailable)
@available(*, unavailable, message: "Please use `IQKeyboardToolbar` independently https://github.com/hackiftekhar/IQKeyboardToolbar or through `IQKeyboardToolbarManager` from https://github.com/hackiftekhar/IQKeyboardToolbarManager")
@MainActor
@objc public final class IQBarButtonItemConfigurationDeprecated: NSObject {

    @objc public init(systemItem: UIBarButtonItem.SystemItem, action: Selector? = nil) {
        self.systemItem = systemItem
        self.image = nil
        self.title = nil
        self.action = action
        super.init()
    }

    @objc public init(image: UIImage, action: Selector? = nil) {
        self.systemItem = nil
        self.image = image
        self.title = nil
        self.action = action
        super.init()
    }

    @objc public init(title: String, action: Selector? = nil) {
        self.systemItem = nil
        self.image = nil
        self.title = title
        self.action = action
        super.init()
    }

    public let systemItem: UIBarButtonItem.SystemItem?
    @objc public let image: UIImage?
    @objc public let title: String?
    @objc public var action: Selector?
    @objc public override var accessibilityLabel: String? { didSet { } }
}

@available(*, unavailable, message: "Please use `IQKeyboardToolbarManager` independently from https://github.com/hackiftekhar/IQKeyboardToolbarManager")
@objc public enum IQAutoToolbarManageBehaviorDeprecated: Int {
    case bySubviews
    case byTag
    case byPosition
}

@available(*, unavailable, message: "Please use `IQKeyboardToolbarManager` independently from https://github.com/hackiftekhar/IQKeyboardToolbarManager")
@objc public enum IQPreviousNextDisplayModeDeprecated: Int {
    case `default`
    case alwaysHide
    case alwaysShow
}

@available(*, unavailable, message: "Please use `IQKeyboardToolbarManager` independently from https://github.com/hackiftekhar/IQKeyboardToolbarManager")
@MainActor
@objc public final class IQToolbarConfigurationDeprecated: NSObject {

    @objc public var useTextInputViewTintColor: Bool = false
    @objc public var tintColor: UIColor?
    @objc public var barTintColor: UIColor?
    @objc public var previousNextDisplayMode: IQPreviousNextDisplayModeDeprecated = .default
    @objc public var manageBehavior: IQAutoToolbarManageBehaviorDeprecated = .bySubviews
    @objc public var previousBarButtonConfiguration: IQBarButtonItemConfigurationDeprecated?
    @objc public var nextBarButtonConfiguration: IQBarButtonItemConfigurationDeprecated?
    @objc public var doneBarButtonConfiguration: IQBarButtonItemConfigurationDeprecated?
    @objc public let placeholderConfiguration: IQToolbarPlaceholderConfigurationDeprecated = .init()
}

@available(*, unavailable, message: "Please use `IQKeyboardToolbarManager` independently from https://github.com/hackiftekhar/IQKeyboardToolbarManager")
@MainActor
public extension IQKeyboardManager {

    @objc var enableAutoToolbar: Bool {
        get { false }
        set { }
    }

    @objc var toolbarConfiguration: IQToolbarConfigurationDeprecated {
        get { IQToolbarConfigurationDeprecated()}
        set { }
    }

    @objc var toolbarPreviousNextAllowedClasses: [UIView.Type] {
        get { [] }
        set { }
    }

    @objc var disabledToolbarClasses: [UIViewController.Type] {
        get { [] }
        set { }
    }

    @objc var enabledToolbarClasses: [UIViewController.Type] {
        get { [] }
        set { }
    }

    @objc var playInputClicks: Bool {
        get { false }
        set { }
    }
    @objc func reloadInputViews() {}
}
// swiftlint:enable line_length
// swiftlint:enable unused_setter_value
// swiftlint:enable type_name
